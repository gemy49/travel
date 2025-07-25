import 'package:flutter/material.dart';
import 'package:FlyHigh/models/hotel.dart';

class HotelDetailsScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/Hotels/${hotel.image}",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                // Hotel name
                Text(
                  hotel.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.teal),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hotel.city,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Available rooms: ${hotel.availableRooms}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Rate: ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    ...List.generate(5, (index) {
                      if (index < hotel.rate.floor()) {
                        return const Icon(Icons.star, color: Colors.amber, size: 20);
                      } else if (index < hotel.rate && hotel.rate - index >= 0.5) {
                        return const Icon(Icons.star_half, color: Colors.amber, size: 20);
                      } else {
                        return const Icon(Icons.star_border, color: Colors.amber, size: 20);
                      }
                    }),
                    const SizedBox(width: 6),
                    Text(
                      hotel.rate.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price
                Row(
                  children: [
                    const Icon(Icons.price_check, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      '\$${hotel.price.toStringAsFixed(2)} per night',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
