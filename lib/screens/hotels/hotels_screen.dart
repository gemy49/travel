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
  double _maxPrice = 500; // الحد الأقصى للسعر للتصفية

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      _hotelProvider.fetchHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);

    final filteredHotels = hotelProvider.hotels
        .where((hotel) => hotel.price <= _maxPrice)
        .toList();

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Filter by Price (Max: \$${_maxPrice.toInt()})",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  inactiveColor: Colors.grey,
                  activeColor: Colors.blue.shade400,
                  min: 100,
                  max: 500,
                  divisions: 10,
                  value: _maxPrice,
                  label: _maxPrice.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      _maxPrice = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Hotel List
          filteredHotels.isEmpty
              ? const Center(
              child: Text("No hotels found in this price range."))
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredHotels.length,
            itemBuilder: (context, index) {
              final hotel = filteredHotels[index];
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/hotel-details',
                    arguments: hotel,
                  );
                },
                child: HotelCard(hotel: hotel),
              );
            },
          ),
        ],
      ),
        ),
    );
  }
}
