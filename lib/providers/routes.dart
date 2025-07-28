import 'package:flutter/material.dart';

// --- Correctly import FlightDetailsScreen ---
// Make sure this path matches the actual location of your FlightDetailsScreen file.
import 'package:FlyHigh/screens/flights/flight_details_screen.dart';
// If FlightBookingData is defined inside flight_details_screen.dart, this import should make it accessible.
// If you moved FlightBookingData to its own file (recommended), import it like this:
// import 'package:FlyHigh/models/flight_booking_data.dart'; // Adjust path if needed

// --- Correctly import HotelDetailsScreen ---
import 'package:FlyHigh/screens/hotels/hotel_details_screen.dart';

// --- Import Models ---
import 'package:FlyHigh/models/flight.dart';
import 'package:FlyHigh/models/hotel.dart';// --- Correctly import Flight_Payment ---
// Make sure this path matches the actual location of your Flight_Payment file.
import 'package:FlyHigh/screens/flights/Flight_payment.dart';

import '../models/Flights_booking_data.dart'; // Adjust path if needed (e.g., lib/screens/payments/flight_payment.dart)

// If FlightBookingData is defined *inside* Flight_Payment.dart, you might need to import it from there instead.
// However, defining it in its own model file (e.g., lib/models/flight_booking_data.dart) is better practice.
// If it's defined in Flight_Payment.dart and you must import it from there:
// import 'package:FlyHigh/screens/Flight_payment.dart' show FlightBookingData; // Only import FlightBookingData
// OR import the whole file and use the full name: Flight_Payment.FlightBookingData (if it's nested)

class RouteGenerator {
  static Route<dynamic>generateRoute(RouteSettings settings) {
    // Print the route name for debugging
    print('RouteGenerator: Attempting to generate route for ${settings.name}');
    print('RouteGenerator: Arguments received: ${settings.arguments} (Type: ${settings.arguments.runtimeType})');

    switch (settings.name!) {
      case '/flight-details':
        final args = settings.arguments;
        if (args is Flight) {
          // Ensure FlightDetailsScreen is accessible via the import
          return MaterialPageRoute(
            builder: (_) => FlightDetailsScreen(flight: args),
          );
        } else if (args is Map<String, dynamic>) {
          final flight = args['flight'] as Flight?;
          if (flight != null) {
            return MaterialPageRoute(
              builder: (_) =>FlightDetailsScreen(flight: flight),
            );
          }
        }
        print('RouteGenerator: Invalid arguments for /flight-details: $args');
        return _errorRoute();

      case '/hotel-details':
        final args = settings.arguments;
        if (args is Hotel) {
          // Ensure HotelDetailsScreen is accessible via the import
          return MaterialPageRoute(
            builder: (_) => HotelDetailsScreen(hotel: args),
          );
        }
        print('RouteGenerator: Invalid arguments for /hotel-details: $args');
        return _errorRoute();

      case '/Flight_Payment': // Ensure this matches the string used in Navigator.pushNamed exactly, including case.
        final args = settings.arguments;

        // --- Option 1:If FlightBookingData is passed directly (Preferred) ---
        if (args is FlightBookingData) {
          print('RouteGenerator: Navigating to Flight_Payment with FlightBookingData');
          return MaterialPageRoute(
            builder: (_) => Flight_Payment(bookingData: args), // Ensure Flight_Payment constructor accepts bookingData
          );
        }
        // --- Option 2: If a Flight object is passed, create FlightBookingData ---
        else if (args is Flight) {
          print('RouteGenerator: Navigating to Flight_Payment with Flight object, creating default FlightBookingData');
          // Create FlightBookingData with a default number of seats (e.g., 1)
          final bookingData = FlightBookingData(flight: args, numberOfAdults: 1,numberOfChildren: 0);
          return MaterialPageRoute(
            builder: (_) =>Flight_Payment(bookingData: bookingData),
          );
        }
        // --- Option 3: If passing as a Map ---
        else if (args is Map<String, dynamic>) {
          print('RouteGenerator: Navigating to Flight_Payment with Map arguments');
          final flight = args['flight'] as Flight?;
          final int numberOfAdults = args['numberOfSeats'] as int? ?? 1; // Provide default
          final int numberOfChildren = args['numberOfChildren'] as int? ?? 1; // Provide default
          if (flight != null) {
            final bookingData = FlightBookingData(flight: flight, numberOfAdults: numberOfAdults,numberOfChildren:numberOfChildren );
            return MaterialPageRoute(
              builder: (_) => Flight_Payment(bookingData: bookingData),
            );
          }
        }
        // --- Error Case: Unexpected or missing arguments ---
        print('RouteGenerator: Invalid arguments for /Flight_Payment: $args');
        return _errorRoute();

      default:
        print('RouteGenerator: Route not found for ${settings.name}');
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    print('RouteGenerator: Returning error route');
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Error: Page not found')),
      ),
    );
  }
}