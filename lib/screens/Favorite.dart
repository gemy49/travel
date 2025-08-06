import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../providers/counter_bloc.dart';
import '../../providers/counter_state.dart';
import '../../providers/flight_provider.dart';
import 'flights/flight_card.dart';

class FavoriteFlightsScreen extends StatefulWidget {
  const FavoriteFlightsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteFlightsScreen> createState() => _FavoriteFlightsScreenState();
}

class _FavoriteFlightsScreenState extends State<FavoriteFlightsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<CounterBloc>().fetchFavoritesFromServer();
    await Provider.of<FlightProvider>(context, listen: false).fetchFlights();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, PageState>(
      builder: (context, state) {
        final favoriteIds = state.favoriteIds;
        final allFlights = context.read<FlightProvider>().flights;
        final flights = allFlights
            .where((flight) => favoriteIds.contains(flight.id))
            .toList();

        return RefreshIndicator(
          color: Colors.blue.shade500,
          onRefresh: _loadData, // لما تسحب لتحديث
          child: Container(
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
              physics: const AlwaysScrollableScrollPhysics(), // مهم عشان يشتغل حتى لو القائمة صغيرة
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
          ),
        );
      },
    );
  }
}
