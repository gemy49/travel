import 'package:FlyHigh/models/hotel.dart';

class HotelBookingData {
  final Hotel hotel;
  final List<Map<String, dynamic>> selectedRooms; // e.g., [{'type': 'Deluxe', 'quantity': 2, 'pricePerNight': 150.0, 'totalPriceForType': 300.0}]
  final double totalPrice;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  HotelBookingData({
    required this.hotel,
    required this.selectedRooms,
    required this.totalPrice,
    required this.checkInDate,
    required this.checkOutDate,
  });
}