import 'package:flutter/material.dart';

// Screens
import 'package:travel_booking_app/screens/flights/flight_details_screen.dart';

// Models
import 'package:travel_booking_app/models/flight.dart';
import 'package:travel_booking_app/models/hotel.dart';

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
              builder: (_) =>
                  FlightDetailsScreen(flight: flight, selectedHotel: hotel),
            );
          }
        }

        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Error: Page not found'))),
    );
  }
}
