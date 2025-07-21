import 'package:flutter/material.dart';
import 'package:FlyHigh/models/hotel.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onSelect;

  const HotelCard({Key? key, required this.hotel, required this.onSelect})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(hotel.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City: ${hotel.city}'),
            Text('Price: \$${hotel.price}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onSelect,
          child: const Text("Select"),
        ),
      ),
    );
  }
}
