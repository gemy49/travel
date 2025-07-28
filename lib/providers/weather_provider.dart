import 'package:flutter/material.dart';
import 'package:FlyHigh/models/weather.dart';
import 'package:FlyHigh/services/api_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherResponse? _weather;
  WeatherResponse? get weather => _weather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather({required String city}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final api = ApiService();
      _weather = await api.getWeatherForecast(city);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error fetching weather: $e");
      throw Exception("Failed to load weather");
    }
  }
}
