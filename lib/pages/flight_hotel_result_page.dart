import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class FlightHotelResultPage extends StatelessWidget {
  const FlightHotelResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = Provider.of<BookingProvider>(context);
    final flight = booking.flightInfo;
    final hotel = booking.hotel;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Trip Summary")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: flight == null || hotel == null
            ? const Center(child: Text("Missing flight or hotel data"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Flight Details",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      title: Text("${flight['from']} → ${flight['to']}"),
                      subtitle: Text(
                        "Departure: ${flight['departureDate']}\nReturn: ${flight['returnDate']}",
                      ),
                      leading: const Icon(Icons.flight_takeoff),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Hotel Details",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      title: Text(hotel.name),
                      subtitle: Text("${hotel.city} • \$${hotel.price}"),
                      leading: const Icon(Icons.hotel),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Trip booked successfully!"),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Confirm Booking"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
