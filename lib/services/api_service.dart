import 'package:http/http.dart' as http;
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
  // inside ApiService class

  /// Book a hotel room
  Future<void> bookHotel({
    required int hotelId,
    required String roomType,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/hotels/$hotelId/book');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'roomType': roomType,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to book hotel: ${response.body}');
    }
  }

  Future<void> createOrUpdateUserOnServer(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        print("Error creating user on server: ${response.body}");
      } else {
        print("User created/exists on server");
      }
    } catch (e) {
      print("Error connecting to server: $e");
    }
  }
  Future<void> addHotelBookingForUser({
    required String email,
    required Map<String, dynamic> bookingData,
  }) async {
    final url = Uri.parse("$baseUrl/users/$email/hotel-bookings");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bookingData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to save booking to server: ${response.body}");
    }
  }
  Future<List<HotelBooking>> getUserHotelBookings(String email) async {
    final res = await http.get(Uri.parse("$baseUrl/users/$email/hotel-bookings"));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => HotelBooking.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load bookings");
    }
  }

  Future<void> cancelHotelBooking({required String email, required String bookingId}) async {
    final res = await http.post(
      Uri.parse("$baseUrl/users/$email/cancel-hotel-booking"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"bookingId": bookingId}),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to cancel booking");
    }
  }
  Future<void> addFavorite({
    required String email,
    required String id,
    required String type,
  }) async {
    final url = Uri.parse("$baseUrl/users/$email/favorites");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "type": type,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add favorite: ${response.body}");
    }

    print("✅ Favorite added: ${response.body}");
  }

  /// إزالة عنصر من المفضلة
  Future<void> removeFavorite({
    required String email,
    required String id,
    required String type,
  }) async {
    final url = Uri.parse("$baseUrl/users/$email/favorites");

    final response = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "type": type,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove favorite: ${response.body}");
    }

    print("🗑 Favorite removed: ${response.body}");
  }

  Future<List<Favorite>> getUserFavorites(String email) async {
    final res = await http.get(Uri.parse("$baseUrl/users/$email/favorites"));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Favorite.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load favorites");
    }
  }
  Future<List<dynamic>> getBookings(String email) async {
    final res = await http.get(Uri.parse("$baseUrl/users/$email/bookings")); // ✅
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load bookings");
    }
  }

  // 📌 إضافة حجز
  Future<void> bookFlight(
      String email,
      {
        required Map<String, dynamic> bookingData,
      }) async {
    final url = Uri.parse('$baseUrl/users/$email/bookings');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bookingData),
    );

    print("Booking response status: ${response.statusCode}");
    print("Booking response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to book flight: ${response.body}");
    }
  }

  // 📌 حذف حجز
  Future<void> cancelBooking(String email, int flightId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/users/$email/cancel-booking"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"flightId": flightId}),

    );
    if (res.statusCode != 200) {
      throw Exception("Failed to cancel booking");

    }
  }
}
