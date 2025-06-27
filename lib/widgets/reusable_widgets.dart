import 'package:flutter/material.dart';
import '../models/hotel.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;

  const HotelCard({super.key, required this.hotel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(hotel.name),
        subtitle: Text("${hotel.city} • \$${hotel.price}"),
        leading: const Icon(Icons.hotel, color: Colors.indigo),
        onTap: onTap,
      ),
    );
  }
}

class FlightCard extends StatelessWidget {
  final String from;
  final String to;
  final String departureDate;
  final String returnDate;

  const FlightCard({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
    required this.returnDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.flight, color: Colors.indigo),
        title: Text("$from → $to"),
        subtitle: Text("Departure: $departureDate\nReturn: $returnDate"),
      ),
    );
  }
}
