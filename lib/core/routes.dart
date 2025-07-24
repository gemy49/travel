import 'package:flutter/material.dart';

// Screens
import 'package:FlyHigh/screens/flights/flight_details_screen.dart';
import 'package:FlyHigh/screens/hotels/hotel_details_screen.dart';

// Models
import 'package:FlyHigh/models/flight.dart';
import 'package:FlyHigh/models/hotel.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name!) {
      case '/flight-details':
        if (settings.arguments is Flight) {
          final flight = settings.arguments as Flight;
          return MaterialPageRoute(
            builder: (_) => FlightDetailsScreen(flight: flight),
          );
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final flight = args['flight'] as Flight?;
          final hotel = args['hotel'] as Hotel?;

          if (flight != null) {
            return MaterialPageRoute(
              builder: (_) => FlightDetailsScreen(flight: flight),
            );
          }
        }
        return _errorRoute();

      case '/hotel-details': // ✅ Add this route
        if (settings.arguments is Hotel) {
          final hotel = settings.arguments as Hotel;
          return MaterialPageRoute(
            builder: (_) => HotelDetailsScreen(hotel: hotel),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Error: Page not found')),
      ),
    );
  }
}
