import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../widgets/hotel_card.dart';

class HotelDetailsScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailsScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City: ${hotel.city}', style: TextStyle(fontSize: 18)),
            Text('Price: \$${hotel.price}', style: TextStyle(fontSize: 18)),
            Text(
              'Available Rooms: ${hotel.availableRooms}',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(onPressed: () {}, child: const Text("Save Trip")),
          ],
        ),
      ),
    );
  }
}
