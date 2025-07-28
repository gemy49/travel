import 'package:FlyHigh/models/HotelRoom.dart';
import 'package:flutter/material.dart';
import 'package:FlyHigh/models/hotel.dart';
import 'package:url_launcher/url_launcher.dart';
// Assuming you have a route for booking/payment
// import '../screens/hotel_booking_payment_screen.dart'; // Adjust path

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  // Map to store the quantity selected for each room type
  // Key: room type (String), Value: quantity (int)
  Map<String, int> _selectedRoomQuantities = {};

  void _openMap(BuildContext context, double latitude, double longitude) async {
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
              content: Text(
                  'Cannot open maps. Please ensure a maps app is installed.'),
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

  // Function to update the quantity for a specific room type
  void _updateRoomQuantity(String roomType, int change) {
    setState(() {
      int currentQuantity = _selectedRoomQuantities[roomType] ?? 0;
      int newQuantity = currentQuantity + change;

      // Ensure quantity doesn't go below 0
      if (newQuantity < 0) newQuantity = 0;

      if (newQuantity == 0) {
        // Remove entry if quantity is 0
        _selectedRoomQuantities.remove(roomType);
      } else {
        // Update the quantity
        _selectedRoomQuantities[roomType] = newQuantity;
      }
    });
  }

  // Calculate the total price based on selected rooms
  double _calculateTotalPrice() {
    double total = 0.0;
    _selectedRoomQuantities.forEach((roomType, quantity) {
      // Find the room details in the hotel's availableRooms list
      final room = widget.hotel.availableRooms.firstWhere(
            (r) => r.type == roomType,
        // --- UPDATED LINE ---
        orElse: () => availableRoom(type: roomType, price: 0, quantity: 0), // Return availableRoom instance
      );
      total += room.price * quantity;
    });
    return total;
  }

  // Prepare data for booking (e.g., list of selected room types and quantities)
  List<Map<String, dynamic>> _getSelectedRoomsData() {
    List<Map<String, dynamic>> selectedData = [];
    _selectedRoomQuantities.forEach((roomType, quantity) {
      if (quantity > 0) {
        final room = widget.hotel.availableRooms.firstWhere(
              (r) => r.type == roomType,
          // --- UPDATED LINE ---
          orElse: () => availableRoom(type: roomType, price: 0, quantity: 0), // Return availableRoom instance
        );
// Add to selectedData map, ensuring property names match availableRoom
        selectedData.add({
          'type': roomType,
          'quantity': quantity,
          'pricePerNight': room.price, // Use 'price' property
          'totalPriceForType': room.price * quantity,
        });
      }
    });
    return selectedData;
  }

  // Handle booking action
  void _handleBooking(BuildContext context) {
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

    // TODO: Navigate to booking/payment screen, passing selected data and total price

    String summary = "Booking Summary:\n";
    for (var roomData in selectedRoomsData) {
      summary +=
      "${roomData['quantity']} x ${roomData['type']} (\$${roomData['pricePerNight']} each) = \$${roomData['totalPriceForType']}\n";
    }
    summary += "Total: \$${totalPrice.toStringAsFixed(2)}";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(summary),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define primary color based on the chip color from previous designs (File 2)
    final Color primaryColor = Colors.blue.shade500;

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5), // Consistent background
      body: CustomScrollView(
        slivers: [
          // Custom AppBar with primary color
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryColor, // Use primary color
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.hotel.name, // Keep hotel name as is
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
                    "assets/Hotels/${widget.hotel.image}",
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

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description card
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
                            'Description', // English
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor, // Use primary color
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.hotel.description,
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

                  // Location section
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
                              color: primaryColor, // Use primary color
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.hotel.city,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                _openMap(context, 25.1415548, 55.1862657); // Example coords
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor, // Use primary color
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.map, size: 18),
                              label: const Text("View on Map"), // English
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Amenities section (remains the same)
                  Text(
                    "Amenities:", // English
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor, // Use primary color
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.hotel.amenities
                        .map((amenity) =>
                        _buildAmenityChip(amenity, primaryColor))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Rating section (remains the same)
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
                          'Rating:', // English
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor, // Use primary color
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              if (index < widget.hotel.rate.floor()) {
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 30,
                                );
                              } else if (index < widget.hotel.rate &&
                                  widget.hotel.rate - index >= 0.5) {
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
                              widget.hotel.rate.toStringAsFixed(1),
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

                  // Rooms section - Updated for selection
                  Text(
                    "Select Rooms:", // Updated title
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor, // Use primary color
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.hotel.availableRooms.map((room) {
                    final int selectedQuantity =
                        _selectedRoomQuantities[room.type] ?? 0;
                    return _buildRoomSelectionRow(room, selectedQuantity,
                        primaryColor); // Use new helper
                  }).toList(),
                  const SizedBox(height: 10),

                  // Display Total Price
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

                  // Book Button
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
                      onPressed: () => _handleBooking(context), // Call handler
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Book Now', // English
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

  // Helper Widget: Builds a row for selecting room quantity
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
          // Room Type and Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.type,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${room.price.toStringAsFixed(2)} per night',
                style: const TextStyle(
                    fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          // Quantity Selector
          Row(
            children: [
              // Minus Button
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: primaryColor),
                onPressed: () {
                  _updateRoomQuantity(room.type, -1);
                },
              ),
              // Quantity Display
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$selectedQuantity',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              // Plus Button
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: primaryColor),
                onPressed: () {
                  // Optional: Check if adding exceeds available quantity
                  if (selectedQuantity < room.quantity) {
                    _updateRoomQuantity(room.type, 1);
                  } else {
                    // Show snackbar or disable button if limit reached
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Only ${room.quantity} ${room.type}(s) available.'),
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

  // Amenity chip (remains the same) - now accepts primary color
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
            color: Colors.blue, // Or primaryColor
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            amenity,
            style: const TextStyle(
              color: Colors.blue, // Or primaryColor
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Example HotelRoom model structure (ensure your model matches this) ---
// class HotelRoom {
//   final String type;
//   final double price; // Changed to double
//   final int quantity; // Available quantity

//   HotelRoom({required this.type, required this.price, required this.quantity});
// }