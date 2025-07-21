import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../providers/hotel_provider.dart';
import '../providers/place_provider.dart';
import '../screens/flights/flights_screen.dart';
import '../screens/hotels/hotels_screen.dart';
import '../screens/places/places_screen.dart';
import '../screens/saved/saved_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Travel Planner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FlightsScreen()),
              ),
              child: const Text("Find Flights"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HotelsScreen(city: "Dubai"),
                ),
              ),
              child: const Text("Find Hotels"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlacesScreen()),
              ),
              child: const Text("Explore Places"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SavedScreen()),
              ),
              child: const Text("Saved Trips"),
            ),
          ],
        ),
      ),
    );
  }
}
