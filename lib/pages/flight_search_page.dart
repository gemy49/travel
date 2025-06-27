import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../providers/booking_provider.dart';
import '../services/flight_service.dart';
import 'hotel_search_page.dart';

class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key});

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  final _formKey = GlobalKey<FormState>();

  Map<String, String> _cities = {}; // name: id
  String? _fromCityName;
  String? _toCityName;
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _loadingCities = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities([String query = 'a']) async {
    setState(() => _loadingCities = true);
    try {
      final cities = await FlightService.fetchCities(query);
      setState(() {
        _cities = {for (var c in cities) c.name: c.id};
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch cities: $e')));
    } finally {
      setState(() => _loadingCities = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final fromId = _cities[_fromCityName]!;
      final toId = _cities[_toCityName]!;

      Provider.of<BookingProvider>(context, listen: false).setFlightInfo(
        from: fromId,
        to: toId,
        departureDate: _departureDate!,
        returnDate: _returnDate!,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HotelSearchPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineSmall;

    return Scaffold(
      appBar: AppBar(title: const Text("Flight Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingCities
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text("Choose your flight", style: headline),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "From"),
                      value: _fromCityName,
                      items: _cities.keys.map((cityName) {
                        return DropdownMenuItem(
                          value: cityName,
                          child: Text(cityName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _fromCityName = val),
                      validator: (val) =>
                          val == null ? 'Please select departure city' : null,
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "To"),
                      value: _toCityName,
                      items: _cities.keys.map((cityName) {
                        return DropdownMenuItem(
                          value: cityName,
                          child: Text(cityName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _toCityName = val),
                      validator: (val) =>
                          val == null ? 'Please select destination city' : null,
                    ),

                    const SizedBox(height: 16),

                    ListTile(
                      title: const Text("Departure Date"),
                      subtitle: Text(
                        _departureDate == null
                            ? "Select date"
                            : DateFormat.yMMMEd().format(_departureDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                    if (_departureDate == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "Required",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    ListTile(
                      title: const Text("Return Date"),
                      subtitle: Text(
                        _returnDate == null
                            ? "Select date"
                            : DateFormat.yMMMEd().format(_returnDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                    if (_returnDate == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "Required",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed:
                          (_fromCityName != null &&
                              _toCityName != null &&
                              _departureDate != null &&
                              _returnDate != null)
                          ? _submit
                          : null,
                      icon: const Icon(Icons.search),
                      label: const Text("Search Flights & Hotels"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
