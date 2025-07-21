import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/flight.dart';
import '../../models/hotel.dart';
import '../../widgets/flight_card.dart';
import '../../widgets/hotel_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Flight> savedFlights = [];
  List<Hotel> savedHotels = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTrips();
  }

  Future<void> _loadSavedTrips() async {
    final prefs = await SharedPreferences.getInstance();

    final flightsJson = prefs.getStringList('saved_flights') ?? [];
    final flights = flightsJson
        .map((f) => Flight.fromJson(json.decode(f)))
        .toList();

    final hotelsJson = prefs.getStringList('saved_hotels') ?? [];
    final hotels = hotelsJson
        .map((h) => Hotel.fromJson(json.decode(h)))
        .toList();

    setState(() {
      savedFlights = flights;
      savedHotels = hotels;
    });
  }

  Future<void> _removeFlight(Flight flight) async {
    final prefs = await SharedPreferences.getInstance();
    final flightsJson = prefs.getStringList('saved_flights') ?? [];
    final flights = flightsJson.map((f) => json.decode(f)).toList();

    flights.removeWhere((f) => f['id'] == flight.id);
    final updatedFlights = flights.map((f) => json.encode(f)).toList();

    await prefs.setStringList('saved_flights', updatedFlights);
    setState(() {
      savedFlights.remove(flight);
    });
  }

  Future<void> _removeHotel(Hotel hotel) async {
    final prefs = await SharedPreferences.getInstance();
    final hotelsJson = prefs.getStringList('saved_hotels') ?? [];
    final hotels = hotelsJson.map((h) => json.decode(h)).toList();

    hotels.removeWhere((h) => h['id'] == hotel.id);
    final updatedHotels = hotels.map((h) => json.encode(h)).toList();

    await prefs.setStringList('saved_hotels', updatedHotels);
    setState(() {
      savedHotels.remove(hotel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Trips")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (savedFlights.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saved Flights",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  for (var flight in savedFlights)
                    Dismissible(
                      key: Key('flight-${flight.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeFlight(flight),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: FlightCard(
                        flight: flight,
                        onDetailsPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/flight-details',
                            arguments: {'flight': flight},
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),

            if (savedHotels.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saved Hotels",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  for (var hotel in savedHotels)
                    Dismissible(
                      key: Key('hotel-${hotel.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeHotel(hotel),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: HotelCard(
                        hotel: hotel,
                        onSelect: () {
                          Navigator.pushNamed(
                            context,
                            '/hotel-details',
                            arguments: hotel,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),

            if (savedFlights.isEmpty && savedHotels.isEmpty)
              const Center(
                child: Text(
                  "You have no saved trips yet.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
