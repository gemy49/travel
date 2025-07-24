import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/city.dart';
import '../models/flight.dart';
import '../models/hotel.dart';
import '../models/weather.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.100:3000/api';

  // Flights
  Future<List<Flight>> getFlights({
    String? from,
    String? to,
    String? date,
    String? returnDate,
  }) async {
    var url = Uri.parse('$baseUrl/flights');
    if (from != null || to != null || date != null || returnDate != null) {
      url = Uri.parse('$baseUrl/flights?from=$from&to=$to&date=$date');
    }
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Flight.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load flights');
    }
  }

  Future<void> addFlight(Flight flight) async {
    final response = await http.post(
      Uri.parse('$baseUrl/flights'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(flight.toJson()),
    );
    if (response.statusCode != 201) throw Exception('Failed to add flight');
  }

  // Hotels
  Future<List<Hotel>> getHotels({String? city}) async {
    var url = Uri.parse('$baseUrl/hotels');
    if (city != null) {
      url = Uri.parse('$baseUrl/hotels?city=$city');
    }
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load hotels');
    }
  }

  Future<void> addHotel(Hotel hotel) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hotels'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(hotel.toJson()),
    );
    if (response.statusCode != 201) throw Exception('Failed to add hotel');
  }

  // Places
  Future<List<Place>> getPlaces({String? city}) async {
    var url = Uri.parse('$baseUrl/places');
    if (city != null) {
      url = Uri.parse('$baseUrl/places?city=$city');
    }
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Place.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }
  Future<List<City>> getCities() async {
    final response = await http.get(Uri.parse('$baseUrl/places'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => City.fromJson(json)).toList();
    } else {
      throw Exception('فشل تحميل المدن');
    }
  }

  // Weather Forecast
  Future<WeatherResponse> getWeatherForecast(String city) async {
    final apiKey = 'fe929c8b878144e880e225611231508';
    final url = Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=3&aqi=no&alerts=no');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherResponse.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
