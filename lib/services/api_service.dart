import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/flight.dart';
import '../models/hotel.dart';
import '../models/place.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000/api';

  // Flights
  Future<List<Flight>> getFlights({
    String? from,
    String? to,
    String? date,
  }) async {
    var url = Uri.parse('$baseUrl/flights');
    if (from != null || to != null || date != null) {
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
}
