import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../providers/counter_bloc.dart';
import '../../models/city.dart';
import '../../providers/place_provider.dart';

class PublicPlacesPage extends StatefulWidget {
  const PublicPlacesPage({super.key});

  @override
  State<PublicPlacesPage> createState() => _PublicPlacesPageState();
}

class _PublicPlacesPageState extends State<PublicPlacesPage> {
  late String city;
  bool _isLoading = true;

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as int;
    city = _getCityNameById(id);
    _loadPlaces();
  }


  String _getCityNameById(int id) {
    final cities = ['London', 'Dubai', 'Paris', 'Tokyo','Cairo'];
    return cities[id];
  }

  Future<void> _loadPlaces() async {
    try {
      await context.read<PlaceProvider>().fetchPlaces(city: city);
    } catch (e) {
      print("خطأ أثناء تحميل الأماكن: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlaceProvider>().places;

    return Scaffold(
      appBar: AppBar(title: Text('Places in $city'),
          useDefaultSemanticsOrder: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final Place place = places[index];
          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    "assets/places/${place.image}",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
