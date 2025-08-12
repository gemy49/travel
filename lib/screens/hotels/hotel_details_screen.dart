// lib/screens/hotels/hotel_details_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
// Assuming HotelRoom is defined within hotel.dart or imported separately
// import 'package:FlyHigh/models/hotel_room.dart'; // If separate
import 'package:FlyHigh/models/hotel.dart';
import 'package:FlyHigh/models/hotel_booking_data.dart'; // You'll need this model
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your providers
import '../../providers/hotel_provider.dart';
import 'Hotel_payment.dart'; // Adjust path

class HotelDetailsScreen extends StatefulWidget {
  // Accept either the full Hotel object OR just the ID
  final Hotel? hotel; // Make hotel nullable
  final int? hotelId; // Add hotelId parameter

  const HotelDetailsScreen({super.key, this.hotel, this.hotelId})
      : assert(hotel != null || hotelId != null, 'Either hotel or hotelId must be provided'),
        assert(!(hotel != null && hotelId != null), 'Cannot provide both hotel and hotelId');

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  // State for the hotel data and loading state
  Hotel? _hotel;
  bool _isLoading = true;
  String _errorMessage = '';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  late TextEditingController _checkInDateController;
  late TextEditingController _checkOutDateController;
  // State for room selection (as before)
  Map<String, int> _selectedRoomQuantities = {};

  @override
  void initState() {
    super.initState();
    _selectedRoomQuantities = <String, int>{};

    // Initialize date controllers
    _checkInDateController = TextEditingController();
    _checkOutDateController = TextEditingController();
    if (widget.hotel != null) {
      // If hotel object is provided directly, use it
      _hotel = widget.hotel;
      setState(() {
        _isLoading = false;
      });
    } else if (widget.hotelId != null) {
      // If only hotelId is provided, fetch the hotel data
      _fetchHotelById(widget.hotelId!);
    }
  }

  Future<void> _fetchHotelById(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Access the HotelProvider
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

      // Ensure hotels are loaded
      if (hotelProvider.hotels.isEmpty) {
        await hotelProvider.fetchHotels();
      }

      // Find the hotel by ID
      final Hotel? foundHotel =
      hotelProvider.hotels.firstWhere((hotel) => hotel.id == id, ); // Provide a default/fallback

      if (foundHotel != null && foundHotel.id != 0) { // Assuming ID 0 means not found or empty
        setState(() {
          _hotel = foundHotel;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Hotel with ID $id not found.';
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching hotel by ID: $error");
      setState(() {
        _errorMessage = 'Failed to load hotel details.';
        _isLoading = false;
      });
    }
  }

  // --- Room selection logic (as before) ---
  void _updateRoomQuantity(String roomType, int change) {
    setState(() {
      int currentQuantity = _selectedRoomQuantities[roomType] ?? 0;
      int newQuantity = currentQuantity + change;
      if (newQuantity < 0) newQuantity = 0;
      if (newQuantity == 0) {
        _selectedRoomQuantities.remove(roomType);
      } else {
        _selectedRoomQuantities[roomType] = newQuantity;
      }
    });
  }

  // Inside the _HotelDetailsScreenState class

  /// Calculates the total price based on selected rooms and number of nights.
  double _calculateTotalPrice() {
    if (_hotel == null) return 0.0;

    // --- Calculate number of nights ---
    int numberOfNights = 1; // Default to 1 night if dates are not selected or invalid
    if (_checkInDate != null && _checkOutDate != null) {
      // Calculate the difference in days
      numberOfNights = _checkOutDate!.difference(_checkInDate!).inDays;
      // Ensure it's at least 1 night
      if (numberOfNights <= 0) {
        numberOfNights = 1;
      }
    }
    // --- End calculate number of nights ---

    double total = 0.0;
    _selectedRoomQuantities.forEach((roomType, quantity) {
      if (quantity > 0) { // Only calculate for rooms with quantity > 0
        final room = _hotel!.availableRooms.firstWhere(
              (r) => r.type == roomType,
          orElse: () => availableRoom(type: roomType, price: 0, quantity: 0),
        );
        // Multiply by price, quantity, and number of nights
        total += room.price * quantity * numberOfNights;
      }
    });
    return total;
  }

  List<Map<String, dynamic>> _getSelectedRoomsData() {
    if (_hotel == null) return [];
    List<Map<String, dynamic>> selectedData = [];
    _selectedRoomQuantities.forEach((roomType, quantity) {
      if (quantity > 0) {
        final room = _hotel!.availableRooms.firstWhere(
              (r) => r.type == roomType,
          orElse: () => availableRoom(type: roomType, price: 0, quantity: 0),
        );
        selectedData.add({
          'type': roomType,
          'quantity': quantity,
          'pricePerNight': room.price,
          'totalPriceForType': room.price * quantity,
        });
      }
    });
    return selectedData;
  }

  void _handleBooking(BuildContext context) {
    if (_hotel == null) return;
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both check-in and check-out dates."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final double totalPrice = _calculateTotalPrice();
    final List<Map<String, dynamic>> selectedRoomsData = _getSelectedRoomsData();

    if (selectedRoomsData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one room.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bookingData = HotelBookingData(
      hotel: _hotel!, // Use the fetched hotel
      selectedRooms: selectedRoomsData,
      totalPrice: totalPrice,
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelPaymentScreen(bookingData: bookingData),
      ),
    );
  }

  Future<void> openMap(String lat, String lng) async {
    final Uri googleMapsAppUrl = Uri.parse("comgooglemaps://?q=$lat,$lng");
    final Uri googleMapsWebUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    // حاول يفتح تطبيق Google Maps أولًا
    if (await canLaunchUrl(googleMapsAppUrl)) {
      await launchUrl(googleMapsAppUrl, mode: LaunchMode.externalApplication);
    }
    // لو مش موجود افتح المتصفح
    else {
      await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
    }
  }// Function to select check-in date
  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? today, // Default to today or previously selected
      firstDate: today, // Cannot select a past date
      lastDate: DateTime(today.year + 1), // Allow selection up to a year in the future
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        // Format and display the selected date
        _checkInDateController.text = "${picked.day}/${picked.month}/${picked.year}";

        // If check-out date is before the new check-in date, reset check-out
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
          _checkOutDateController.clear();
        }
      });
    }
  }

// Function to select check-out date
  Future<void> _selectCheckOutDate(BuildContext context) async {
    // Ensure check-in date is selected first
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a check-in date first."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? _checkInDate!.add(const Duration(days: 1)), // Default to day after check-in
      firstDate: _checkInDate!.add(const Duration(days: 1)), // Must be after check-in
      lastDate: _checkInDate!.add(const Duration(days: 365)), // Allow up to a year stay
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
        // Format and display the selected date
        _checkOutDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
  void dispose() {
    // Dispose of room selection related resources if any (as before)

    // Dispose of date controllers
    _checkInDateController.dispose();
    _checkOutDateController.dispose();

    super.dispose();
  }
  // --- UI Building (mostly as before, but using _hotel) ---
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade500;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty || _hotel == null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage.isEmpty ? 'Hotel data is missing.' : _errorMessage)),
      );
    }

    // Use the fetched _hotel object
    final hotel = _hotel!;

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hotel.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/Hotels/${hotel.image}",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hotel.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              hotel.city, // Or hotel.location if more specific
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Use actual coordinates if available
                                openMap(hotel.lat ?? "", hotel.lng ?? "");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.map, size: 18),
                              label: const Text("View on Map"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Select Rooms:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Display available rooms with selection UI
                  ...hotel.availableRooms.map((room) {
                    final int selectedQuantity = _selectedRoomQuantities[room.type] ?? 0;
                    return _buildRoomTypeCard(room, selectedQuantity, primaryColor);
                  }).toList(),
                  const SizedBox(height: 10),
                  // Display Total Price
                  Text(
                    "Select Dates:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor, // Use the primary color defined earlier
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _checkInDateController,
                          readOnly: true, // Make it read-only to force using the picker
                          decoration: InputDecoration(
                            labelText: "Check-in Date",
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onTap: () => _selectCheckInDate(context), // Open date picker on tap
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: _checkOutDateController,
                          readOnly: true, // Make it read-only to force using the picker
                          decoration: InputDecoration(
                            labelText: "Check-out Date",
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onTap: () => _selectCheckOutDate(context), // Open date picker on tap
                        ),
                      ),
                    ],
                  ),
                  if (_checkInDate != null && _checkOutDate != null)
                    Builder( // Use Builder to access context if needed inside the logic
                      builder: (context) {
                        final int nights = _checkOutDate!.difference(_checkInDate!).inDays;
                        if (nights > 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Stay Duration: $nights Night${nights > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: primaryColor, // Use your primary color
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink(); // Return empty widget if nights <= 0
                        }
                      },
                    ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Amenities:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hotel.amenities
                        .map((amenity) => _buildAmenityChip(amenity, primaryColor))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Phone Number
                        if (hotel.contact['phone'] != null &&
                            hotel.contact['phone'].toString().isNotEmpty)
                          _buildContactItem(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: hotel.contact['phone'].toString(),
                            primaryColor: primaryColor,
                            onTap: () {
                              // Add phone call functionality here if needed
                              launch('tel:${hotel.contact['phone']}');
                              print("Phone tapped: ${hotel.contact['phone']}");
                            },
                          ),
                        const SizedBox(height: 12),
                        // Email Address
                        if (hotel.contact['email'] != null &&
                            hotel.contact['email'].toString().isNotEmpty)
                          _buildContactItem(
                            icon: Icons.email,
                            label: 'Email',
                            value: hotel.contact['email'].toString(),
                            primaryColor: primaryColor,
                            onTap: () {
                              // Add email functionality here if needed
                               launch('mailto:${hotel.contact['email']}');
                              print("Email tapped: ${hotel.contact['email']}");
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              if (index < hotel.rate.floor()) {
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 30,
                                );
                              } else if (index < hotel.rate &&
                                  hotel.rate - index >= 0.5) {
                                return const Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 30,
                                );
                              } else {
                                return const Icon(
                                  Icons.star_border,
                                  color: Colors.amber,
                                  size: 30,
                                );
                              }
                            }),
                            const SizedBox(width: 10),
                            Text(
                              hotel.rate.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _handleBooking(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets (as before, using local variables) ---
  Widget _buildRoomTypeCard(dynamic room, int selectedQuantity, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Space between room cards
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Subtle shadow
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Type Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room.type,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, // Use primary color for the type
                  ),
                ),
                // Display available quantity
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200, // Light background for quantity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Available: ${room.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Price per Night
            Text(
              '\$${room.price.toStringAsFixed(2)} per night',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Quantity:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    // Minus Button
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: selectedQuantity > 0 ? primaryColor : Colors.grey,
                      ),
                      onPressed: selectedQuantity > 0
                          ? () {
                        _updateRoomQuantity(room.type, -1);
                      }
                          : null, // Disable if quantity is 0
                    ),
                    // Quantity Display
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$selectedQuantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Plus Button
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: selectedQuantity < room.quantity
                            ? primaryColor
                            : Colors.grey, // Disable if max quantity reached
                      ),
                      onPressed: selectedQuantity < room.quantity
                          ? () {
                        _updateRoomQuantity(room.type, 1);
                      }
                          : null, // Disable if max quantity reached
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String amenity, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.blue,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            amenity,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildContactItem({
  required IconData icon,
  required String label,
  required String value,
  required Color primaryColor,
  VoidCallback? onTap, // Optional: Make it tappable
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8), // Add tap feedback
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Optional: Add an arrow icon to indicate it's tappable
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
        ],
      ),
    ),
  );
}
// --- End of new