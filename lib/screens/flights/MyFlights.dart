// lib/screens/my_flights_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:FlyHigh/models/flight.dart';

import '../../services/storage_keys.dart'; // Adjust path

class MyFlightsScreen extends StatefulWidget {
  const MyFlightsScreen({Key? key}) : super(key: key);

  @override
  State<MyFlightsScreen> createState() => _MyFlightsScreenState();
}

class _MyFlightsScreenState extends State<MyFlightsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true; // Show loading indicator while fetching
    });
    try {
      // --- Use user-specific key ---
      final String? userKey = await getUserSpecificKey('flight_bookings');
      if (userKey == null) {
        // Handle case where user email is not found (e.g., not logged in)
        print("Could not load flight bookings: User email not found.");
        setState(() {
          _bookings = []; // Show empty list or an error message in UI
          _isLoading = false;
        });
        return;
      }
      // --- End user-specific key ---

      final prefs = await SharedPreferences.getInstance();
      // --- Use userKey instead of hardcoded 'flight_bookings' ---
      final List<String>? bookingsJsonList = prefs.getStringList(userKey);
      // --- End change ---
      if (bookingsJsonList != null) {
        List<Map<String, dynamic>> loadedBookings = [];
        for (String bookingJson in bookingsJsonList) {
          try {
            Map<String, dynamic> bookingMap = jsonDecode(bookingJson);
            loadedBookings.add(bookingMap);
          } catch (e) {
            print("Error decoding a flight booking JSON: $e");
            // Optionally, remove corrupt entries or handle them differently
          }
        }
        setState(() {
          _bookings = loadedBookings;
        });
      } else {
        // Handle case where no bookings exist for this user key
        setState(() {
          _bookings = [];
        });
      }
    } catch (e) {
      print("Error loading flight bookings: $e");
      // Optionally, show an error message to the user
      setState(() {
        // _bookings remains previous value or empty
        // Optionally set an error message variable to display in UI
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Optional: Function to clear all bookings (useful for testing)
  Future<void> _clearAllBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('flight_bookings');
    setState(() {
      _bookings = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All bookings cleared")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade500; // Use consistent color

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Flights"),
        foregroundColor: Colors.black,
        actions: [
          // Optional: Add a clear button for testing
          // IconButton(
          //   icon: const Icon(Icons.delete_forever),
          //   onPressed: _clearAllBookings,
          //   tooltip: "Clear All Bookings",
          // ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? const Center(
        child: Text(
          "No flights booked yet.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final bookingData = _bookings[index];
          final flightData = bookingData['flight'];
          // Create a Flight object from the map data for easier handling
          // Handle potential missing or incorrect data gracefully
          Flight? flight;
          try {
            flight = Flight(
              id: flightData['id'] as int? ?? 0,
              from: flightData['from'] as String? ?? 'Unknown',
              to: flightData['to'] as String? ?? 'Unknown',
              date: flightData['date'] as String? ?? 'Unknown',
              returnDate: flightData['returnDate'] as String? ?? 'Unknown',
              departureTime: flightData['departureTime'] as String? ?? 'Unknown',
              arrivalTime: flightData['arrivalTime'] as String? ?? 'Unknown',
              price: (flightData['price'] is num) ? (flightData['price'] as num).toDouble() : 0.0, // Ensure double
              airline: flightData['airline'] as String? ?? 'Unknown',
              // Initialize other required fields with defaults or null checks
              // transit: null, // Or parse if needed
            );
          } catch (e) {
            print("Error creating Flight object from data: $e");
            // Return a placeholder or error widget for this item
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                title: const Text("Error loading booking"),
                subtitle: Text("Details might be corrupted: $e"),
              ),
            );
          }

          final int numberOfAdults = bookingData['numberOfAdults'] as int? ?? 0;
          final int numberOfChildren = bookingData['numberOfChildren'] as int? ?? 0;
          final double totalPrice = bookingData['totalPrice'] is num ? (bookingData['totalPrice'] as num).toDouble() : 0.0;

          return _buildBookingCard(
            context,
            flight!,
            numberOfAdults,
            numberOfChildren,
            totalPrice,
            primaryColor,
          );
        },
      ),
    );
  }

  // Helper Widget: Builds a card for a single booking
  Widget _buildBookingCard(BuildContext context, Flight flight, int adults, int children, double totalPrice, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flight Route Header
            Row(
              children: [
                Icon(Icons.flight_takeoff, color: primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${flight.from} to ${flight.to}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
                Icon(Icons.flight_land, color: primaryColor),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),

            // Flight Details
            _buildDetailRow(Icons.calendar_today, "Departure", "${flight.date} at ${flight.departureTime}"),
            _buildDetailRow(Icons.calendar_today, "Return", "${flight.returnDate} at ${flight.arrivalTime}"),
            _buildDetailRow(Icons.airlines, "Airline", flight.airline),
            _buildDetailRow(Icons.confirmation_number, "Flight Number", "FL${flight.id}"), // Example ID usage
            const SizedBox(height: 5),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 5),

            // Booking Summary
            _buildDetailRow(Icons.person, "Adults", adults.toString()),
            if (children > 0) _buildDetailRow(Icons.child_care, "Children", children.toString()),
            const SizedBox(height: 5),
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

  // Helper Widget: Builds a row for flight/booking details
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(), // Pushes value to the end
          Text(value),
        ],
      ),
    );
  }
}