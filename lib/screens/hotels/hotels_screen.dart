import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FlyHigh/providers/hotel_provider.dart';
import 'package:FlyHigh/screens/hotels/hotel_card.dart';

class HotelsScreen extends StatefulWidget {
  final String city;

  const HotelsScreen({Key? key, required this.city}) : super(key: key);

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  late HotelProvider _hotelProvider;
  double _maxPrice = 500;
  List<int> _selectedRatings = []; // To track selected ratings
  String? _selectedCity; // To track selected city
  bool _showChips = false; // To show chips when filters are applied

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      _hotelProvider.fetchHotels();
    });
  }

  // Toggle rating selection
  void _toggleRating(int rating) {
    setState(() {
      if (_selectedRatings.contains(rating)) {
        _selectedRatings.remove(rating);
      } else {
        _selectedRatings.add(rating);
      }
      _showChips = _selectedRatings.isNotEmpty ||
          _maxPrice < 500 ||
          (_selectedCity != null && _selectedCity != widget.city);
    });
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _maxPrice = 500;
      _selectedRatings.clear();
      _selectedCity = null;
      _showChips = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    // Get unique cities from hotels data
    final List<String> cities = hotelProvider.hotels
        .map((hotel) => hotel.city)
        .toSet()
        .toList()
      ..sort();
    final List<int> price = hotelProvider.hotels
        .expand((hotel) => hotel.availableRooms.map((room) => room.price))
        .toSet()
        .toList()
      ..sort();

    // Apply filters
    final filteredHotels = hotelProvider.hotels
        .where((hotel) =>
    hotel.availableRooms.isNotEmpty &&
        hotel.availableRooms
            .map((room) => room.price)
            .reduce((a, b) => a < b ? a : b) <=
            _maxPrice)
        .where((hotel) {
      if (_selectedRatings.isEmpty) return true;
      return _selectedRatings.contains(hotel.rate);
    })
    .where((hotel) {
      // If no city selected or selected city is the default, show all
      if (_selectedCity == null || _selectedCity == widget.city) return true;
      // Show hotels that match selected city
      return hotel.city == _selectedCity;
    })
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips - Show when filters are applied
                  if (_showChips) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Active Filters:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold
                          ),
                        ),
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text("Clear All",style: TextStyle(color: Colors.blue.shade500)),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_maxPrice < 500)
                          Chip(
                            backgroundColor: Colors.white,
                            label: Text("Max Price: \$${_maxPrice.toInt()}"),
                            onDeleted: () {
                              setState(() {
                                _maxPrice = 500;
                                _showChips = _selectedRatings.isNotEmpty ||
                                    (_selectedCity != null && _selectedCity != widget.city);
                              });
                            },
                          ),
                        ..._selectedRatings.map(
                              (rating) => Chip(
                            backgroundColor: Colors.white,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("$rating"),
                                Icon(Icons.star, size: 16, color: Colors.amber),
                              ],
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedRatings.remove(rating);
                                _showChips = _selectedRatings.isNotEmpty ||
                                    _maxPrice < 500 ||
                                    (_selectedCity != null && _selectedCity != widget.city);
                              });
                            },
                          ),
                        ),
                        if (_selectedCity != null && _selectedCity != widget.city)
                          Chip(
                            backgroundColor: Colors.white,
                            label: Text("City: $_selectedCity"),
                            onDeleted: () {
                              setState(() {
                                _selectedCity = null;
                                _showChips = _selectedRatings.isNotEmpty ||
                                    _maxPrice < 500;
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],

                  // City Filter
                  Text(
                    "Filter by City:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: _selectedCity,
                    hint: Text("Select City"),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text("All Cities"),
                      ),
                      ...cities.map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _showChips = _selectedRatings.isNotEmpty ||
                            _maxPrice < 500 ||
                            (value != null && value != widget.city);
                      });
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Price Filter
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
                        _showChips = _selectedRatings.isNotEmpty ||
                            _maxPrice < 500 ||
                            (_selectedCity != null && _selectedCity != widget.city);
                      });
                    },
                  ),
                  SizedBox(height: 5),

                  // Rating Filter
                  Text(
                    "Filter by Rating:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    children: List.generate(5, (index) {
                      int rating = 1 + index;
                      bool isSelected = _selectedRatings.contains(rating);
                      return ChoiceChip(
                        backgroundColor:Colors.white ,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("$rating"),
                            Icon(Icons.star, size: 16, color: Colors.amber),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: Colors.blue.shade100,
                        onSelected: (selected) {
                          _toggleRating(rating);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Hotel List
            filteredHotels.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No hotels found with selected filters."),
              ),
            )
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