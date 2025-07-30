import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FlyHigh/models/hotel.dart';
import '../../models/MyHotels.dart';
import '../../services/api_service.dart';

class MyHotelsScreen extends StatefulWidget {
  const MyHotelsScreen({Key? key}) : super(key: key);

  @override
  State<MyHotelsScreen> createState() => _MyHotelsScreenState();
}

class _MyHotelsScreenState extends State<MyHotelsScreen>
    with SingleTickerProviderStateMixin {
  List<HotelBooking> _hotelBookings = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadHotelBookings();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHotelBookings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      print("Email from prefs: $email");

      if (email == null) {
        setState(() {
          _hotelBookings = [];
          _isLoading = false;
        });
        return;
      }

      final bookingsJson = await ApiService().getUserHotelBookings(email);
      print("Bookings JSON from API: $bookingsJson");
      setState(() {
        _hotelBookings = List<HotelBooking>.from(bookingsJson);
      });
    } catch (e) {
      print("Error loading bookings: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _animationController.forward();
      });
    }
  }


  Future<void> _deleteBooking(int index) async {
    final booking = _hotelBookings[index];

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      if (email == null) return;

      await ApiService()
          .cancelHotelBooking(email: email, bookingId: booking.bookingId);

      setState(() {
        _hotelBookings.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Booking deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to delete booking: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Hotel Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hotelBookings.isEmpty
          ? _buildEmptyState()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0, vertical: 16.0),
          itemCount: _hotelBookings.length,
          itemBuilder: (context, index) {
            final booking = _hotelBookings[index];

            final hotel = Hotel(
              id: booking.hotelId,
              city: booking.city,
              location: '',
              name: booking.hotelName,
              onSale: false,
              rate: 0,
              image: '',
              description: '',
              amenities: [],
              contact: {},
              availableRooms: [],
            );

            return _buildHotelBookingCard(
              context,
              hotel,
              booking.rooms,
              booking.totalCost,
              primaryColor,
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("No hotels booked yet.",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            "Explore hotels and make your first booking!",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHotelBookingCard(
      BuildContext context,
      Hotel hotel,
      List<BookedRoom> selectedRooms,
      double totalPrice,
      Color primaryColor,
      int index,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.hotel, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(hotel.city,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: const Text(
                            "Are you sure you want to delete this hotel booking?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deleteBooking(index);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300], thickness: 0.8),
            const SizedBox(height: 16),
            const Text("Booked Rooms",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...selectedRooms.map((room) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Text("${room.quantity} x ${room.type}")),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300], thickness: 0.8),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Paid:",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text("\$${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
