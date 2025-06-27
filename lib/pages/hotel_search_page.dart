import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';
import '../providers/booking_provider.dart';
import 'flight_hotel_result_page.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  List<Hotel> _hotels = [];
  double _maxPrice = 500;
  bool _loading = false;

  // قائمة بالمدن و ID الخاص بها
  final Map<String, String> _cities = {
    'Cairo': '-2092174',
    'Dubai': '-782831',
    'Istanbul': '-755070',
    'Paris': '-1456928',
    'New York': '-255031',
  };

  String _selectedCity = 'Dubai';

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    setState(() => _loading = true);

    try {
      final hotels = await HotelService.fetchHotels(
        destId: _cities[_selectedCity]!,
      );
      setState(() {
        _hotels = hotels;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load hotels: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineSmall;

    return Scaffold(
      appBar: AppBar(title: const Text("Hotel Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔽 Dropdown لاختيار المدينة + زر بحث
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCity,
                          items: _cities.keys
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCity = value;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Select City',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _fetchHotels,
                        icon: const Icon(Icons.search),
                        label: const Text("Search"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text("Available Hotels", style: headline),
                  const SizedBox(height: 10),

                  // 💰 فلتر السعر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Max Price:"),
                      Text("\$${_maxPrice.toInt()}"),
                    ],
                  ),
                  Slider(
                    value: _maxPrice,
                    min: 50,
                    max: 1000,
                    divisions: 20,
                    label: "\$${_maxPrice.toInt()}",
                    onChanged: (value) => setState(() => _maxPrice = value),
                  ),
                  const SizedBox(height: 10),

                  // 📃 عرض الفنادق
                  Expanded(
                    child: _hotels.isEmpty
                        ? const Center(child: Text("No hotels found."))
                        : ListView(
                            children: _hotels
                                .where((h) => h.price <= _maxPrice)
                                .map(
                                  (hotel) => Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(hotel.name),
                                      subtitle: Text(
                                        "${hotel.city} • \$${hotel.price}",
                                      ),
                                      leading: const Icon(Icons.hotel),
                                      onTap: () {
                                        Provider.of<BookingProvider>(
                                          context,
                                          listen: false,
                                        ).setHotel(hotel);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const FlightHotelResultPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
