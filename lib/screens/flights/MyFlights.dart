import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FlyHigh/models/MyFlights.dart';
import 'package:FlyHigh/services/api_service.dart';

class MyFlightsScreen extends StatefulWidget {
  const MyFlightsScreen({Key? key}) : super(key: key);

  @override
  State<MyFlightsScreen> createState() => _MyFlightsScreenState();
}

class _MyFlightsScreenState extends State<MyFlightsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  final Color primary = Colors.blue.shade500;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  /// 🔹 دالة موحدة لعرض الرسائل
  void _showSnackBar(Color bgColor, IconData icon, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? '';

    if (userId.toString().isEmpty) {
      setState(() {
        _bookings = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await ApiService().getBookings();
      setState(() {
        _bookings = data
            .map<Booking>((json) => Booking.fromJson(json))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          Colors.red,
          Icons.error_outline,
          "Failed to load bookings: $e",
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(String flightId) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) return;

    try {
      await ApiService().cancelBooking(email, flightId);
      if (mounted) {
        _showSnackBar(
          Colors.green,
          Icons.check_circle_outline,
          "Booking cancelled successfully",
        );
      }
      await _loadBookings();
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          Colors.red,
          Icons.error_outline,
          "Failed to cancel booking: $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Flight Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                return _buildFlightBookingCard(
                  context,
                  _bookings[index],
                  primary,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplanemode_active_outlined, size: 60, color: primary),
          const SizedBox(height: 16),
          const Text(
            "No flights booked yet.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "Explore flights and make your first booking!",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFlightBookingCard(
    BuildContext context,
    Booking booking,
    Color primaryColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Airline Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    booking.airline.isNotEmpty ? booking.airline[0] : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Route Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.from,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.flight_takeoff,
                            color: primaryColor,
                            size: 20,
                          ),
                          Expanded(
                            child: Text(
                              booking.to,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            booking.date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "ID: FL${booking.id}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Confirm Cancellation"),
                        content: Text(
                          "Cancel booking from ${booking.from} to ${booking.to}?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("No"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _cancelBooking(booking.bFId);
                            },
                            child: const Text("Yes, Cancel"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300], height: 1, thickness: 0.8),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildDetailItem(
                  Icons.access_time,
                  "Departure",
                  "${booking.date} at ${booking.departureTime}",
                  primaryColor,
                ),
                _buildDetailItem(
                  Icons.access_time_filled,
                  "Arrival",
                  "${booking.date} at ${booking.arrivalTime}",
                  primaryColor,
                ),
                _buildDetailItem(
                  Icons.airlines,
                  "Airline",
                  booking.airline,
                  primaryColor,
                ),
                _buildDetailItem(
                  Icons.attach_money,
                  "Price",
                  "\$${booking.price.toStringAsFixed(2)}",
                  primaryColor,
                ),
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.person,
                      "Adults",
                      booking.adults.toString(),
                      primaryColor,
                    ),
                    const SizedBox(width: 50),
                    _buildDetailItem(
                      Icons.child_care,
                      "Children",
                      booking.children.toString(),
                      primaryColor,
                    ),
                  ],
                ),
                if (booking.transit != null)
                  _buildDetailItem(
                    Icons.location_city,
                    "Transit",
                    "${booking.transit!['transitCity']} (${booking.transit!['transitDuration']})",
                    primaryColor,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300], height: 1, thickness: 0.8),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Passengers:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "${booking.adults + booking.children}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Price:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "\$${booking.totalPrice.toStringAsFixed(2) }",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color primaryColor,
  ) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
