import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/api_service.dart';

class HotelProvider with ChangeNotifier {
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  double _minPrice = 0;
  double _maxPrice = double.infinity;

  List<Hotel> get hotels => _filteredHotels;

  Future<void> fetchHotels() async {
    final api = ApiService();
    _hotels = await api.getHotels();
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
    _filteredHotels = _hotels.where((hotel) {
      if (hotel.availableRooms.isEmpty) return false;

      int minRoomPrice = hotel.availableRooms.map((room) => room.price).reduce((a, b) => a < b ? a : b);

      return minRoomPrice >= _minPrice && minRoomPrice <= _maxPrice;
    }).toList();

    notifyListeners();
  }

}
