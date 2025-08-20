import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as shared_preferences;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/MyHotels.dart';
import '../models/city.dart';
import '../models/favorite.dart';
import '../models/flight.dart';
import '../models/hotel.dart';
import '../models/weather.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.100:3000/api';

  // ===== Helper to get stored userId =====
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<String?> _Authorization() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });

    final response = await http.post(url, headers: headers, body: body);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': responseData};
    } else {
      return {
        'success': false,
        'error': responseData['error'] ?? 'Registration failed.',
      };
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': responseData};
    } else {
      return {
        'success': false,
        'error': responseData['error'] ?? 'Login failed',
      };
    }
  }

  // ===== Flights =====
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

  // ===== Hotels =====
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

  // ===== Places =====
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

  // ===== Favorites =====
  Future<void> addFavorite({
    required int favoriteId,
    required String type,
    required airline,
    required flightNumber,
    required from,
    required to,
    required departureTime,
    required arrivalTime,
    required date,
    required price,
    required name,
    required city,
    required image,
    required description,
    required rate,
    required location,
  }) async {
    final userId = await _getUserId();
    final token = await _Authorization();
    if (userId == null) throw Exception("User ID not found");

    final url = Uri.parse("$baseUrl/users/$userId/favorites");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "favoriteId": favoriteId, // ✅ مطابق مع Node API
        "type": type,
        "airline": airline,
        "flightNumber": flightNumber,
        "from": from,
        "to": to,
        "departureTime": departureTime,
        "arrivalTime": arrivalTime,
        "date": date,
        "price": price,
        "name": name,
        "city": city,
        "image": image,
        "description": description,
        "rate": rate,
        "location": location,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add favorite: ${response.body}");
    }
  }

  Future<void> removeFavorite({
    required int favoriteId,
    required String type,
  }) async {
    final userId = await _getUserId();
    final token = await _Authorization();

    if (userId == null) throw Exception("User ID not found");

    final url = Uri.parse("$baseUrl/users/$userId/favorites");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"favoriteId": favoriteId, "type": type}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove favorite: ${response.body}");
    }
  }

  Future<List<Favorite>> getUserFavorites() async {
    final userId = await _getUserId();
    final token = await _Authorization();
    if (userId == null) throw Exception("User ID not found");

    final res = await http.get(
      Uri.parse("$baseUrl/users/$userId/favorites"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Favorite.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load favorites");
    }
  }

  // ===== Flight Bookings =====
  Future<List<dynamic>> getBookings() async {
    final userId = await _getUserId();
    final token = await _Authorization();

    if (userId == null) throw Exception("User ID not found");
    if (token == null) throw Exception("Token not found");

    final res = await http.get(
      Uri.parse("$baseUrl/users/$userId/bookings"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load bookings: ${res.body}");
    }
  }

  Future<void> bookFlight({required Map<String, dynamic> bookingData}) async {
    final userId = await _getUserId();
    final token = await _Authorization();

    if (userId == null) throw Exception("User ID not found");
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse('$baseUrl/users/$userId/bookings');
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(bookingData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to book flight: ${response.body}");
    }
  }

  // ===== Cancel Booking (تركته زي ما هو) =====
  Future<void> cancelBooking(String email, String flightId) async {
    final userId = await _getUserId();
    final token = await _Authorization();

    if (userId == null) throw Exception("User ID not found");

    final res = await http.post(
      Uri.parse("$baseUrl/users/$userId/cancel-booking"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"bFId": flightId}),
    );
    if (res.statusCode != 200) {
      print(res.body);
      throw Exception("Failed to cancel booking");
    }
  }

  // ===== Hotel Bookings =====
  Future<List<HotelBooking>> getUserHotelBookings() async {
    final userId = await _getUserId();
    final token = await _Authorization();

    if (userId == null) throw Exception("User ID not found");
    if (token == null) throw Exception("Token not found");

    final res = await http.get(
      Uri.parse("$baseUrl/users/$userId/hotel-bookings"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("🔍 Status Code: ${res.statusCode}");
    print("🔍 Response Body: ${res.body}");

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => HotelBooking.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load bookings: ${res.body}");
    }
  }

  Future<void> addHotelBookingForUser({
    required Map<String, dynamic> bookingData,
  }) async {
    final userId = await _getUserId();
    final token = await _Authorization();

    if (userId == null) throw Exception("User ID not found");

    final url = Uri.parse("$baseUrl/users/$userId/hotel-bookings");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

      body: jsonEncode(bookingData),
    );
    print("🔍 Status Code: ${response.statusCode}");
    print("🔍 Response Body: ${response.body}");
    if (response.statusCode != 200) {
      throw Exception("Failed to save booking to server: ${response.body}");
    }
  }

  Future<void> bookRoom({
    required int id,
    required int quantity,
    required String roomType,
  }) async {
    final token = await _Authorization();
    if (token == null) throw Exception("Token not found");
    final url = Uri.parse("$baseUrl/hotels/$id/book");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"quantity": quantity, "roomType": roomType}),
    );
    if (response.statusCode != 200) {
      throw Exception(
        "Failed to save booking room  to server: ${response.body}",
      );
    }
  }

  Future<void> cancelHotelBooking({required String bookingId}) async {
    final userId = await _getUserId();
    final token = await _Authorization();
    if (userId == null) throw Exception("User ID not found");

    final res = await http.post(
      Uri.parse("$baseUrl/users/$userId/cancel-hotel-booking"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"bookingId": bookingId}),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to cancel booking");
    }
  }

  Future<WeatherResponse> getWeatherForecast(String city) async {
    final apiKey = 'fe929c8b878144e880e225611231508';
    final url = Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=3&aqi=no&alerts=no',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherResponse.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> sendResetEmail(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    final data = json.decode(response.body);

    return {'statusCode': response.statusCode, 'data': data};
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'token': token,
        'newPassword': newPassword,
      }),
    );

    final data = json.decode(response.body);

    return {'statusCode': response.statusCode, 'data': data};
  }

  Future<bool> updateProfilePhoto({required String profilePhotoUrl}) async {
    final userId = await _getUserId();
    final token = await _Authorization();

    final response = await http.put(
      Uri.parse("$baseUrl/users/$userId/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({"profilePhoto": profilePhotoUrl}),
    );

    print("🔹 Status Code: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    return response.statusCode == 200;
  }

  Future<String?> getProfilePhoto() async {
    final userId = await _getUserId();
    final token = await _Authorization();

    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId/profile"),
      headers: {"Authorization": "Bearer $token"},
    );
    print("🔹 Status Code: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["profilePhoto"] as String?;
    }
    return null;
  }

}
