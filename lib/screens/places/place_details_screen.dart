import 'package:flutter/material.dart';
import '../../models/city.dart';

class PlacesPage extends StatelessWidget {
  final City city;

  const PlacesPage({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(city.name)),
      body: ListView.builder(
        itemCount: city.places.length,
        itemBuilder: (context, index) {
          final place = city.places[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                Image.asset(
                  "assets/places/${place.image}",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    place.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
