// lib/models/flight_booking_data.dart (or wherever you define it)
import 'package:FlyHigh/models/flight.dart';

class FlightBookingData {
  final Flight flight;
  final int numberOfAdults;
  final int numberOfChildren;
  // Optional: If you want to store the calculated total price
  // final double totalPrice;

  FlightBookingData({
    required this.flight,
    required this.numberOfAdults,
    required this.numberOfChildren,
    // this.totalPrice, // Include if needed
  });

// Optional: Add a getter to calculate total price here as well
// double get totalPrice => (flight.price * numberOfAdults) + (flight.price * 0.5 * numberOfChildren);
}