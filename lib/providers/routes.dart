// lib/core/routes.dart
import 'package:flutter/material.dart';
import 'package:FlyHigh/screens/flights/flight_details_screen.dart';
import 'package:FlyHigh/screens/hotels/hotel_details_screen.dart'; // Make sure this import is correct
import 'package:FlyHigh/screens/flights/Flight_payment.dart';
import 'package:FlyHigh/screens/flights/MyFlights.dart'; // Make sure this import is correct
// import 'package:FlyHigh/screens/hotels/MyHotels.dart'; // Import MyHotelsScreen if you have it

import 'package:FlyHigh/models/flight.dart';
import 'package:FlyHigh/models/hotel.dart';
// import 'package:provider/provider.dart'; // Not needed here anymore
import '../models/Flights_booking_data.dart'; // Adjust path if needed

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('RouteGenerator: Attempting to generate route for ${settings.name}');
    print('RouteGenerator: Arguments received: ${settings.arguments} (Type: ${settings.arguments.runtimeType})');

    switch (settings.name!) {
      case '/flight-details':
        final args = settings.arguments;
        if (args is Flight) {
          return MaterialPageRoute(
            builder: (_) => FlightDetailsScreen(flight: args),
          );
        } else if (args is Map<String, dynamic>) {
          final flight = args['flight'] as Flight?;
          if (flight != null) {
            return MaterialPageRoute(
              builder: (_) => FlightDetailsScreen(flight: flight),
            );
          }
        }
        print('RouteGenerator: Invalid arguments for /flight-details: $args');
        return _errorRoute();

      case '/hotel-details':
        final args = settings.arguments;
        // Option 1: Directly pass the Hotel object (Preferred if you have it)
        if (args is Hotel) {
          return MaterialPageRoute(
            builder: (_) => HotelDetailsScreen(hotel: args),
          );
        }
        // Option 2: Pass the hotel ID (int) - HotelDetailsScreen will fetch data
        else if (args is int) {
          // Pass the hotel ID to the HotelDetailsScreen
          return MaterialPageRoute(
            builder: (_) => HotelDetailsScreen(hotelId: args),
          );
        }
        // Option 3: Pass hotel data as a Map (less ideal for complex objects)
        else if (args is Map<String, dynamic>) {
          // You could handle Map construction here if needed, but passing ID or object is better
          // For now, let's assume Map contains 'id'
          final int? hotelId = args['id'] as int?;
          if (hotelId != null) {
            return MaterialPageRoute(
              builder: (_) => HotelDetailsScreen(hotelId: hotelId),
            );
          }
        }
        print('RouteGenerator: Invalid arguments for /hotel-details: $args');
        return _errorRoute();

      case '/Flight_Payment':
        final args = settings.arguments;

        if (args is FlightBookingData) {
          print('RouteGenerator: Navigating to Flight_Payment with FlightBookingData');
          return MaterialPageRoute(
            builder: (_) => Flight_Payment(bookingData: args),
          );
        } else if (args is Flight) {
          print('RouteGenerator: Navigating to Flight_Payment with Flight object, creating default FlightBookingData');
          // Note: If FlightBookingData now uses numberOfAdults/Children, adjust this
          final bookingData = FlightBookingData(flight: args, numberOfAdults: 1, numberOfChildren: 0);
          return MaterialPageRoute(
            builder: (_) => Flight_Payment(bookingData: bookingData),
          );
        } else if (args is Map<String, dynamic>) {
          print('RouteGenerator: Navigating to Flight_Payment with Map arguments');
          final flight = args['flight'] as Flight?;
          // Note: Extract numberOfAdults/Children if passed in Map
          final int numberOfAdults = args['numberOfAdults'] as int? ?? 1;
          final int numberOfChildren = args['numberOfChildren'] as int? ?? 0;
          if (flight != null) {
            final bookingData = FlightBookingData(flight: flight, numberOfAdults: numberOfAdults, numberOfChildren: numberOfChildren);
            return MaterialPageRoute(
              builder: (_) => Flight_Payment(bookingData: bookingData),
            );
          }
        }
        print('RouteGenerator: Invalid arguments for /Flight_Payment: $args');
        return _errorRoute();

      case '/my-flights':
        return MaterialPageRoute(
          builder: (_) => const MyFlightsScreen(),
        );

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