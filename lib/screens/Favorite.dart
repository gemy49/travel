import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../models/flight.dart';
import '../models/hotel.dart';
import '../providers/counter_bloc.dart';
import '../providers/counter_state.dart';
import '../providers/flight_provider.dart';
import '../providers/hotel_provider.dart';

import '../models/favorite.dart';
import 'flights/flight_card.dart';
import 'hotels/hotel_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<FlightProvider>(context, listen: false).fetchFlights();
    await Provider.of<HotelProvider>(context, listen: false).fetchHotels();
    await context.read<CounterBloc>().fetchFavoritesFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const TabBar(
            tabs: [
              Tab(text: "Flights"),
              Tab(text: "Hotels"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFavoritesList("flight"),
            _buildFavoritesList("hotel"),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(String type) {
    return BlocBuilder<CounterBloc, PageState>(
      builder: (context, state) {
        final favoriteIds = state.favorites
            .where((f) => f.type == type)
            .map((f) => f.id)
            .toList();

        final flights = context.read<FlightProvider>().flights;
        final hotels = context.read<HotelProvider>().hotels;

        final filteredItems = type == "flight"
            ? flights.where((f) => favoriteIds.contains(f.id)).toList()
            : hotels.where((h) => favoriteIds.contains(h.id)).toList();

        return RefreshIndicator(
          onRefresh: _loadData,
          child: filteredItems.isEmpty
              ? Center(child: Text("No favorite $type found."))
              : ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    type == "flight" ? '/flight-details' : '/hotel-details',
                    arguments: item,
                  );
                },
                child: type == "flight"
                    ? FlightCard(flight: item as Flight)
                    : HotelCard(hotel: item as Hotel),
              );
            },
          ),
        );
      },
    );
  }
}
