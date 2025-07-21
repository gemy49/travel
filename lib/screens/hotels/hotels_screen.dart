import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FlyHigh/providers/hotel_provider.dart';
import 'package:FlyHigh/widgets/hotel_card.dart';

class HotelsScreen extends StatefulWidget {
  final String city;

  const HotelsScreen({Key? key, required this.city}) : super(key: key);

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  late HotelProvider _hotelProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      _hotelProvider.fetchHotels(city: widget.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Hotels in ${widget.city}')),
      body: hotelProvider.hotels.isEmpty
          ? const Center(child: Text("No hotels found in this city."))
          : ListView.builder(
              itemCount: hotelProvider.hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotelProvider.hotels[index];
                return HotelCard(
                  hotel: hotel,
                  onSelect: () {
                    Navigator.pushNamed(
                      context,
                      '/hotel-details',
                      arguments: hotel,
                    );
                  },
                );
              },
            ),
    );
  }
}
