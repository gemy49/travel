// lib/screens/hotels/hotel_details_screen.dart

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

  // State for room selection (as before)
  Map<String, int> _selectedRoomQuantities = {};

  @override
  void initState() {
    super.initState();
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

  double _calculateTotalPrice() {
    if (_hotel == null) return 0.0;
    double total = 0.0;
    _selectedRoomQuantities.forEach((roomType, quantity) {
      final room = _hotel!.availableRooms.firstWhere(
            (r) => r.type == roomType,
        orElse: () => availableRoom(type: roomType, price: 0, quantity: 0),
      );
      total += room.price * quantity;
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
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelPaymentScreen(bookingData: bookingData),
      ),
    );
  }

  void _openMap(BuildContext context, double latitude, double longitude) async {
    // Replace with actual coordinates if available in your model
    final Uri mapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(
          mapUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
              Text('Cannot open maps. Please ensure a maps app is installed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening map: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while opening the map.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                                _openMap(context, 25.1415548, 55.1862657);
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
                  ...hotel.availableRooms.map((room) {
                    final int selectedQuantity =
                        _selectedRoomQuantities[room.type] ?? 0;
                    return _buildRoomSelectionRow(
                        room, selectedQuantity, primaryColor);
                  }).toList(),
                  const SizedBox(height: 10),
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
  Widget _buildRoomSelectionRow(
      dynamic room, int selectedQuantity, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.type,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${room.price.toStringAsFixed(2)} per night',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: primaryColor),
                onPressed: () {
                  _updateRoomQuantity(room.type, -1);
                },
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$selectedQuantity',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: primaryColor),
                onPressed: () {
                  if (selectedQuantity < room.quantity) {
                    _updateRoomQuantity(room.type, 1);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Only ${room.quantity} ${room.type}(s) available.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
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

// --- Add this helper to your Hotel model or as a separate utility ---
// In your hotel.dart model file, you might want to add this for the fallback:
// class Hotel {
//   // ... existing fields ...
//   Hotel.empty() // Named constructor for empty state
//       : id = 0,
//         city = '',
//         location = '',
//         name = '',
//         availableRooms = [],
//         onSale = false,
//         rate = 0.0,
//         image = '',
//         description = '',
//         amenities = [],
//         contact = {};
//
//   // ... rest of Hotel class ...
// }