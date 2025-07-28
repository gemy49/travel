import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:FlyHigh/providers/counter_bloc.dart';
import 'package:FlyHigh/providers/flight_provider.dart';
import 'package:FlyHigh/screens/flights/flight_card.dart';
import 'package:provider/provider.dart';

class FavoriteFlightsScreen extends StatelessWidget {
  const FavoriteFlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CounterBloc>();
    final favoriteIds = cubit.state.favoriteIds;

    final flights = Provider.of<FlightProvider>(context).flights;
    final favoriteFlights =
    flights.where((flight) => favoriteIds.contains(flight.id)).toList();

    return Container(
      decoration: BoxDecoration(
       color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: favoriteFlights.isEmpty
            ? const Center(child: Text("No favorite flights found.",style: TextStyle(color: Colors.white,)))
            : ListView.builder(
          itemCount: favoriteFlights.length,
          itemBuilder: (context, index) {
            final flight = favoriteFlights[index];
            return  InkWell(
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
