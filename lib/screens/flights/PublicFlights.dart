import 'package:FlyHigh/providers/flight_provider.dart';
import 'package:FlyHigh/screens/flights/flight_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class PublicFlightsPage extends StatefulWidget {
  const PublicFlightsPage({super.key});

  @override
  State<PublicFlightsPage> createState() => _PublicPlacesPageState();
}

class _PublicPlacesPageState extends State<PublicFlightsPage> {
  late String city;
  bool _isLoading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as int;
    city = _getCityNameById(id);
    city = _getCityNameById(id);
  }


  String _getCityNameById(int id) {
    final cities = ['London', 'Dubai', 'Paris', 'Tokyo','Cairo'];
    if (id < 0 || id >= cities.length) return 'London'; // default fallback
    return cities[id];
  }


  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flightProvider = Provider.of<FlightProvider>(
        context,
        listen: false,
      );
      flightProvider.fetchFlights();
    });
    _LoadFlights();
  }

  Future<void> _LoadFlights() async {
    try {
      await context.read<FlightProvider>().fetchFlights();
    } catch (e) {
      print("خطأ أثناء تحميل الرحلات: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context).flights;
    final flights = flightProvider.where((flight) {
      return flight.to.toLowerCase().contains(city.toLowerCase() );
    }).toList();
    return Scaffold(
      appBar: AppBar(title: Text('Flights to $city'),
        useDefaultSemanticsOrder: true,
      ),
      body: _isLoading? Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: flights.length,
        itemBuilder: (context, index) {
          final  flight = flights[index];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/flight-details',
                arguments: flight,
              );
            },
            child: FlightCard(
              flight: flight,
            ),
          );

        },
      ),
    );
  }
}
