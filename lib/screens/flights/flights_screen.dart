import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FlyHigh/providers/flight_provider.dart';
import 'package:FlyHigh/widgets/flight_card.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({Key? key}) : super(key: key);

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flightProvider = Provider.of<FlightProvider>(
        context,
        listen: false,
      );
      flightProvider.fetchFlights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context);

    return Scaffold(
      body: flightProvider.flights.isEmpty
          ? const Center(child: Text("No flights found."))
          : ListView.builder(
              itemCount: flightProvider.flights.length,
              itemBuilder: (context, index) {
                final flight = flightProvider.flights[index];
                return FlightCard(
                  flight: flight,
                  onDetailsPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/flight-details',
                      arguments: flight,
                    );
                  },
                );
              },
            ),
    );
  }
}
