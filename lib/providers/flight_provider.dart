import 'package:flutter/material.dart';
import 'package:travel_booking_app/models/flight.dart';
import 'package:travel_booking_app/services/api_service.dart';

class FlightProvider with ChangeNotifier {
  List<Flight> _flights = [];
  List<Flight> get flights => _flights;

  Future<void> fetchFlights({String? from, String? to, String? date}) async {
    try {
      final api = ApiService();
      _flights = await api.getFlights(from: from, to: to, date: date);
      notifyListeners();
    } catch (e) {
      print("Error fetching flights: $e");
      // Handle error appropriately, e.g., show a message to the user
      throw Exception("Failed to load flights");
    }
  }
}
