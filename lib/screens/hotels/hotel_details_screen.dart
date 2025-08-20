import 'package:flutter/material.dart';
import 'package:FlyHigh/models/hotel.dart'; // Assuming Hotel model exists
import 'package:FlyHigh/models/hotel_booking_data.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your hotel provider if needed for fetching by ID
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart'; // Adjust path

class HotelDetailsScreen extends StatefulWidget {
  // Accept either the full Hotel object, chat data, or just the ID
  final Hotel? hotel;
  final Map<String, dynamic>? chat; // Accept chat data
  final int? hotelId; // Accept hotelId

  const HotelDetailsScreen({super.key, this.hotel, this.chat, this.hotelId});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  Hotel? _localHotel; // Local variable to hold the hotel data
  bool _isLoading = true; // Add loading state
  String _errorMessage = '';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  late TextEditingController _checkInDateController;
  late TextEditingController _checkOutDateController;
  final Color primaryColor = Colors.blue.shade500;

  // State for room selection
  Map<String, int> _selectedRoomQuantities = {};

  @override
  void initState() {
    super.initState();
    _selectedRoomQuantities = <String, int>{};

    // Initialize date controllers
    _checkInDateController = TextEditingController();
    _checkOutDateController = TextEditingController();

    // Determine the hotel data source
    if (widget.hotel != null) {
      _localHotel = widget.hotel;
      _isLoading = false; // Data is ready
    } else if (widget.chat != null) {
      // Attempt to create a Hotel object from chat data
      try {
        // Map the chat data fields to your Hotel model fields
        // Ensure keys match your API response structure
        _localHotel = Hotel(
          id: int.tryParse(widget.chat!['id']?.toString() ?? '') ?? 0,
          name: widget.chat!['name']?.toString() ?? 'Unknown Hotel',
          description: widget.chat!['description']?.toString() ?? 'No description available.',
          image: widget.chat!['image']?.toString() ?? '',
          city: widget.chat!['city']?.toString() ?? 'Unknown City',
          lat: widget.chat!['lat']?.toString() ?? '',
          lng: widget.chat!['lng']?.toString() ?? '',
          rate: widget.chat!['rate'] is num ? widget.chat!['rate'].toDouble() : 0.0,
          location: widget.chat!['location']?.toString() ?? 'Unknown Location',
          // Safely handle the contact map
          contact: widget.chat!['contact'] is Map<String, dynamic>
              ? widget.chat!['contact'] as Map<String, dynamic>
              : {},
          onSale: widget.chat!['onSale'] as bool? ?? false,
          // You might need to parse these lists from chat data if available
          availableRooms: [],
          amenities: [],
        );
        print("Hotel data extracted from chat: ${_localHotel!.name}");
        _isLoading = false; // Data is ready
      } catch (e, s) {
        print("Error creating Hotel from chat data: $e\nStack: $s");
        setState(() {
          _errorMessage = 'Failed to process hotel data from chat.';
          _isLoading = false;
        });
      }
    } else if (widget.hotelId != null) {
      // If only hotelId is provided, fetch the hotel data
      _fetchHotelById(widget.hotelId!);
    } else {
      // No data provided
      setState(() {
        _errorMessage = 'No hotel data provided.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHotelById(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Access the HotelProvider
      final hotelProvider =
      Provider.of<HotelProvider>(context, listen: false);

      // Ensure hotels are loaded
      if (hotelProvider.hotels.isEmpty) {
        await hotelProvider.fetchHotels();
      }

      // Find the hotel by ID
      final Hotel? foundHotel = hotelProvider.hotels.firstWhere(
            (hotel) => hotel.id == id,
        orElse: () => Hotel(
          id: int.tryParse(widget.chat!['id']?.toString() ?? '') ?? 0,
          name: widget.chat!['name']?.toString() ?? 'Unknown Hotel',
          description: widget.chat!['description']?.toString() ?? 'No description available.',
          image: widget.chat!['image']?.toString() ?? '', // Adjust path handling if needed
          city: widget.chat!['city']?.toString() ?? 'Unknown City',
          lat: widget.chat!['lat']?.toString() ?? '',
          lng: widget.chat!['lng']?.toString() ?? '',
          rate: widget.chat!['rate'] is num ? widget.chat!['rate'].toDouble() : 0.0,
          location: widget.chat!['location']?.toString() ?? 'Unknown Location',
          contact: widget.chat!['contact'] is Map<String, dynamic> ? widget.chat!['contact'] as Map<String, dynamic> : {},
          onSale: widget.chat!['onSale'] ?? false,
          availableRooms: widget.chat!['availableRooms'] ,
          amenities: widget.chat!['amenities'] ,
        ), // Return a default hotel if not found
      );

      if (foundHotel != null && foundHotel.id != 0) {
        setState(() {
          _localHotel = foundHotel;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Hotel with ID $id not found.';
          _isLoading = false;
        });
      }
    } catch (error, stackTrace) {
      print("Error fetching hotel by ID: $error\nStack: $stackTrace");
      setState(() {
        _errorMessage = 'Failed to load hotel details.';
        _isLoading = false;
      });
    }
  }

  // --- Room selection logic ---
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

  /// Calculates the total price based on selected rooms and number of nights.
  double _calculateTotalPrice() {
    if (_localHotel == null) return 0.0;

    int numberOfNights = 1;
    if (_checkInDate != null && _checkOutDate != null) {
      numberOfNights = _checkOutDate!.difference(_checkInDate!).inDays;
      if (numberOfNights <= 0) {
        numberOfNights = 1;
      }
    }

    double total = 0.0;
    _selectedRoomQuantities.forEach((roomType, quantity) {
      if (quantity > 0) {
        // Find the room in _localHotel's availableRooms
        final room = _localHotel!.availableRooms.firstWhere(
              (r) => r.type == roomType,
          orElse: () =>
              availableRoom(type: roomType, price: 0, quantity: 0), // Fallback
        );
        total += room.price * quantity * numberOfNights;
      }
    });
    return total;
  }

  List<Map<String, dynamic>> _getSelectedRoomsData() {
    if (_localHotel == null) return [];
    List<Map<String, dynamic>> selectedData = [];
    _selectedRoomQuantities.forEach((roomType, quantity) {
      if (quantity > 0) {
        final room = _localHotel!.availableRooms.firstWhere(
              (r) => r.type == roomType,
          orElse: () => availableRoom(type: roomType, price: 0, quantity: 0),
        );
        selectedData.add({
          'type': roomType,
          'quantity': quantity,
          'pricePerNight': room.price,
          // Note: This helper returns price for one night. Total price calculation happens in _calculateTotalPrice.
        });
      }
    });
    return selectedData;
  }

  void _handleBooking(BuildContext context) {
    if (_localHotel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_errorMessage.isEmpty
                ? "Hotel data is missing."
                : _errorMessage),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both check-in and check-out dates."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // final double totalPrice = _calculateTotalPrice(); // Not needed here as HotelPaymentScreen can calculate
    final List<Map<String, dynamic>> selectedRoomsData =
    _getSelectedRoomsData();

    if (selectedRoomsData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one room.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create booking data object
    final bookingData = HotelBookingData(
      hotel: _localHotel!,
      selectedRooms: selectedRoomsData,
      totalPrice: _calculateTotalPrice(), // Pass calculated total
      checkInDate: _checkInDate!,
      checkOutDate: _checkOutDate!,
    );

    // Navigate to payment screen
    Navigator.pushNamed(context, '/Hotel_Payment', arguments: bookingData);
  }

  Future<void> openMap(String lat, String lng) async {
    final Uri googleMapsAppUrl = Uri.parse("comgooglemaps://?q=$lat,$lng");
    final Uri googleMapsWebUrl =
    Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapsAppUrl)) {
      await launchUrl(googleMapsAppUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(googleMapsWebUrl)) {
      // Fallback to web URL if app isn't available
      await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
    } else {
      // Handle case where neither can be launched (e.g., show snackbar)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map.')),
        );
      }
    }
  }

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        _checkInDateController.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
          _checkOutDateController.clear();
        }
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
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
      initialDate:
      _checkOutDate ?? _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: _checkInDate!.add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
        _checkOutDateController.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _checkInDateController.dispose();
    _checkOutDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Handle error state
    if (_errorMessage.isNotEmpty || _localHotel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hotel Details')),
        body: Center(
          child: Text(_errorMessage.isEmpty
              ? 'Hotel data is missing.'
              : _errorMessage),
        ),
      );
    }

    // Use the local hotel object
    final hotel = _localHotel!;

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
                        color: Colors.black45)
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ensure the image path is correct relative to your assets
                  Image.asset("assets/Hotels/${hotel.image}",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Handle image loading errors
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.hotel, size: 100),
                        );
                      }),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
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
                  // Description Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          const SizedBox(height: 8),
                          Text(hotel.description,
                              style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Location Card
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
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: primaryColor, size: 28),
                            const SizedBox(width: 10),
                            Text(hotel.city,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                openMap(hotel.lat ?? "", hotel.lng ?? "");
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              icon: const Icon(Icons.map, size: 18),
                              label: const Text("View on Map"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Room Selection Section
                  Text("Select Rooms:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  const SizedBox(height: 12),
                  // Display available rooms
                  if (hotel.availableRooms.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Room information not available.",
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...hotel.availableRooms.map((room) {
                      final int selectedQuantity =
                          _selectedRoomQuantities[room.type] ?? 0;
                      return _buildRoomTypeCard(
                          room, selectedQuantity, primaryColor);
                    }).toList(),
                  const SizedBox(height: 10),
                  // Date Selection Section
                  Text("Select Dates:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _checkInDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Check-in Date",
                            labelStyle: TextStyle(color: primaryColor),
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onTap: () => _selectCheckInDate(context),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: _checkOutDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Check-out Date",
                            labelStyle: TextStyle(color: primaryColor),
                            prefixIcon:
                            const Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: primaryColor, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onTap: () => _selectCheckOutDate(context),
                        ),
                      ),
                    ],
                  ),
                  if (_checkInDate != null && _checkOutDate != null)
                    Builder(
                      builder: (context) {
                        final int nights =
                            _checkOutDate!.difference(_checkInDate!).inDays;
                        if (nights > 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                                'Stay Duration: $nights Night${nights > 1 ? 's' : ''}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor)),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  const SizedBox(height: 15),
                  // Total Price Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor)),
                        Text(
                            '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Amenities Section
                  if (hotel.amenities.isNotEmpty) ...[
                    Text("Amenities:",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hotel.amenities
                          .map((amenity) =>
                          _buildAmenityChip(amenity, primaryColor))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Rating Section
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
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              if (index < hotel.rate.floor()) {
                                return const Icon(Icons.star,
                                    color: Colors.amber, size: 30);
                              } else if (index < hotel.rate &&
                                  hotel.rate - index >= 0.5) {
                                return const Icon(Icons.star_half,
                                    color: Colors.amber, size: 30);
                              } else {
                                return const Icon(Icons.star_border,
                                    color: Colors.amber, size: 30);
                              }
                            }),
                            const SizedBox(width: 10),
                            Text(hotel.rate.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.7)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _handleBooking(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.zero, // Important for gradient
                        ),
                        child: const Text('Book Now',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
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

  // --- Helper Widgets ---
  Widget _buildRoomTypeCard(
      dynamic room, int selectedQuantity, Color primaryColor) {
    // Ensure room is of the correct type (e.g., availableRoom) and has necessary properties
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(room.type,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
                // Display available quantity if needed from room.quantity
                Text("Available: ${room.quantity}",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 5),
            Text('\$${room.price.toStringAsFixed(2)} per night',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quantity:",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color:
                          selectedQuantity > 0 ? primaryColor : Colors.grey),
                      onPressed: selectedQuantity > 0
                          ? () {
                        _updateRoomQuantity(room.type, -1);
                      }
                          : null,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text('$selectedQuantity',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline,
                          color: selectedQuantity < (room.quantity ?? 100)
                              ? primaryColor
                              : Colors.grey), // Assume max 100 if not specified
                      onPressed: selectedQuantity < (room.quantity ?? 100)
                          ? () {
                        _updateRoomQuantity(room.type, 1);
                      }
                          : null,
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
          const Icon(Icons.check_circle, color: Colors.black45, size: 16),
          const SizedBox(width: 4),
          Text(amenity,
              style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Remove the standalone _buildContactItem widget if it's not used within this screen's build method.
// If it is used, make sure it's correctly placed and called.
// Widget _buildContactItem({...}) {...}