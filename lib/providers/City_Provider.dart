import 'package:flutter/material.dart';
import '../models/city.dart';
import '../services/api_service.dart';

class CityProvider with ChangeNotifier {
  List<City> _cities = [];

  List<City> get cities => _cities;

  Future<void> fetchCities() async {
    try {
      final api = ApiService();
      _cities = await api.getCities(); // ✅ استخدم الدالة من ApiService
      notifyListeners();
    } catch (e) {
      print("خطأ أثناء تحميل المدن: $e");
      throw Exception("فشل تحميل المدن");
    }
  }

  City? getCityById(int id) {
    try {
      return _cities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
