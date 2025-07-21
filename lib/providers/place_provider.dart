import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api_service.dart';

class PlaceProvider with ChangeNotifier {
  List<Place> _places = [];
  List<Place> get places => _places;

  Future<void> fetchPlaces({String? city}) async {
    final api = ApiService();
    _places = await api.getPlaces(city: city);
    notifyListeners();
  }
}
