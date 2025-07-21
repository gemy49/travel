import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/api_service.dart';

class HotelProvider with ChangeNotifier {
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  String _city = '';
  double _minPrice = 0;
  double _maxPrice = double.infinity;

  List<Hotel> get hotels => _filteredHotels;

  Future<void> fetchHotels({required String city}) async {
    final api = ApiService();
    _city = city;
    _hotels = await api.getHotels(city: city);
    _applyFilter();
  }

  void setMinPrice(double value) {
    _minPrice = value;
    _applyFilter();
  }

  void setMaxPrice(double value) {
    _maxPrice = value;
    _applyFilter();
  }

  void resetFilters() {
    _minPrice = 0;
    _maxPrice = double.infinity;
    _filteredHotels = _hotels;
    notifyListeners();
  }

  void _applyFilter() {
    _filteredHotels = _hotels
        .where((hotel) => hotel.price >= _minPrice && hotel.price <= _maxPrice)
        .toList();
    notifyListeners();
  }
}
