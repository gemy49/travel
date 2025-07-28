// lib/screens/my_hotels_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:FlyHigh/models/hotel.dart';

import '../../services/storage_keys.dart'; // Adjust path

class MyHotelsScreen extends StatefulWidget {
  const MyHotelsScreen({Key? key}) : super(key: key);

  @override
  State<MyHotelsScreen> createState() => _MyHotelsScreenState();
}

class _MyHotelsScreenState extends State<MyHotelsScreen> {
  List<Map<String, dynamic>> _hotelBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHotelBookings();
  }

// Inside MyHotelsScreen state class
// import 'path/to/utils/storage_keys.dart'; // Adjust import path

  Future<void> _loadHotelBookings() async {
    setState(() {
      _isLoading = true; // Show loading indicator while fetching
    });
    try {
      // --- Use user-specific key ---
      final String? userKey = await getUserSpecificKey('hotel_bookings');
      if (userKey == null) {
        // Handle case where user email is not found
        print("Could not load hotel bookings: User email not found.");
        setState(() {
          _hotelBookings = []; // Show empty list or an error message in UI
          _isLoading = false;
        });
        return;
      }
      // --- End user-specific key ---

      final prefs = await SharedPreferences.getInstance();
      // --- Use userKey instead of hardcoded 'hotel_bookings' ---
      final List<String>? hotelBookingsJsonList = prefs.getStringList(userKey);
      // --- End change ---
      if (hotelBookingsJsonList != null) {
        List<Map<String, dynamic>> loadedBookings = [];
        for (String bookingJson in hotelBookingsJsonList) {
          try {
            Map<String, dynamic> bookingMap = jsonDecode(bookingJson);
            loadedBookings.add(bookingMap);
          } catch (e) {
            print("Error decoding a hotel booking JSON: $e");
            // Optionally, remove corrupt entries or handle them differently
          }
        }
        setState(() {
          _hotelBookings = loadedBookings;
        });
      } else {
        // Handle case where no bookings exist for this user key
        setState(() {
          _hotelBookings = [];
        });
      }
    } catch (e) {
      print("Error loading hotel bookings: $e");
      // Optionally, show an error message to the user
      setState(() {
        // _hotelBookings remains previous value or empty
        // Optionally set an error message variable to display in UI
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // Optional: Function to clear all hotel bookings (useful for testing)
  Future<void> _clearAllHotelBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hotel_bookings');
    setState(() {
      _hotelBookings = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All hotel bookings cleared")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade500; // Use consistent color

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Hotels"),
        foregroundColor: Colors.black,

      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hotelBookings.isEmpty
          ? const Center(
        child: Text(
          "No hotels booked yet.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _hotelBookings.length,
        itemBuilder: (context, index) {
          final bookingData = _hotelBookings[index];
          final hotelData = bookingData['hotel'];
          final List<dynamic> selectedRoomsData = bookingData['selectedRooms'];
          final double totalPrice = bookingData['totalPrice'] is num ? (bookingData['totalPrice'] as num).toDouble() : 0.0;

          // Create a basic Hotel object from the map data for easier handling
          // We only need essential info for display
          Hotel? hotel;
          try {
            hotel = Hotel(
              id: hotelData['id'] as int? ?? 0,
              city: hotelData['city'] as String? ?? 'Unknown City',
              location: hotelData['location'] as String? ?? '', // Might be empty
              name: hotelData['name'] as String? ?? 'Unknown Hotel',
              // availableRooms: [], // Not stored/recreated here
              onSale: false, // Default or not relevant for past bookings?
              rate: (hotelData['rate'] is num) ? (hotelData['rate'] as num).toDouble() : 0.0,
              image: hotelData['image'] as String? ?? '', // Filename
              description: hotelData['description'] as String? ?? '',
              amenities: [], // Default or not relevant for past bookings?
              contact: {},
              availableRooms: [], // Default or not relevant for past bookings?
            );
          } catch (e) {
            print("Error creating Hotel object from data: $e");
            // Return a placeholder or error widget for this item
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                title: const Text("Error loading hotel booking"),
                subtitle: Text("Details might be corrupted: $e"),
              ),
            );
          }

          return _buildHotelBookingCard(
            context,
            hotel!,
            selectedRoomsData.cast<Map<String, dynamic>>(), // Ensure correct typing
            totalPrice,
            primaryColor,
          );
        },
      ),
    );
  }

  // Helper Widget: Builds a card for a single hotel booking
  Widget _buildHotelBookingCard(BuildContext context, Hotel hotel, List<Map<String, dynamic>> selectedRooms, double totalPrice, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Name Header
            Row(
              children: [
                Icon(Icons.hotel, color: primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hotel.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                    overflow: TextOverflow.ellipsis, // Handle long names
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              hotel.city,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),

            // Selected Rooms Summary
            const Text(
              "Booked Rooms:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            ...selectedRooms.map((roomData) {
              final String type = roomData['type'] as String? ?? 'Unknown Room';
              final int quantity = roomData['quantity'] as int? ?? 0;
              // final double pricePerNight = roomData['pricePerNight'] is num ? (roomData['pricePerNight'] as num).toDouble() : 0.0;
              final double totalPriceForType = roomData['totalPriceForType'] is num ? (roomData['totalPriceForType'] as num).toDouble() : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Text(
                      "$quantity x $type",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Spacer(),
                    Text(
                      "\$${totalPriceForType.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),

            // Total Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Paid:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "\$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}