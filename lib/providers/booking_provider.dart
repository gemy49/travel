import 'package:flutter/material.dart';
import '../models/hotel.dart';

class BookingProvider extends ChangeNotifier {
  Map<String, dynamic>? _flightInfo;
  Hotel? _hotel;

  Map<String, dynamic>? get flightInfo => _flightInfo;
  Hotel? get hotel => _hotel;

  void setFlightInfo({
    required String from,
    required String to,
    required DateTime departureDate,
    required DateTime returnDate,
  }) {
    _flightInfo = {
      'from': from,
      'to': to,
      'departureDate': _formatDate(departureDate),
      'returnDate': _formatDate(returnDate),
    };
    notifyListeners();
  }

  void setHotel(Hotel hotel) {
    _hotel = hotel;
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
