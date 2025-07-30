// favorite_flights_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../providers/counter_bloc.dart';
import '../../providers/counter_state.dart';
import '../../providers/flight_provider.dart';
import 'flights/flight_card.dart';

class FavoriteFlightsScreen extends StatelessWidget {
  const FavoriteFlightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, PageState>(
      builder: (context, state) {
        final favoriteIds = state.favoriteIds;
        final allFlights = context.read<FlightProvider>().flights;
        final flights = allFlights
            .where((flight) => favoriteIds.contains(flight.id))
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: flights.isEmpty
              ? const Center(
            child: Text(
              "No favorite flights found.",
              style: TextStyle(color: Colors.black),
            ),
          )
              : ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/flight-details',
                    arguments: flight,
                  );
                },
                child: FlightCard(flight: flight),
              );
            },
          ),
        );
      },
    );
  }
}
