import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';
import 'package:FlyHigh/models/hotel.dart';

class FlightDetailsScreen extends StatelessWidget {
  final Flight flight;
  final Hotel? selectedHotel;

  const FlightDetailsScreen({
    Key? key,
    required this.flight,
    this.selectedHotel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${flight.from} → ${flight.to}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${flight.from}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'To: ${flight.to}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Date: ${flight.date}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Price: \$${flight.price}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Airline: ${flight.airline}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (flight.transit != null) ...[
              Text('Transit City: ${flight.transit!['transitCity']}'),
              Text('Transit Duration: ${flight.transit!['transitDuration']}'),
            ],
            if (selectedHotel != null) ...[
              const SizedBox(height: 20),
              const Text(
                "Selected Hotel",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Hotel Name: ${selectedHotel!.name}'),
              Text('Hotel City: ${selectedHotel!.city}'),
              Text('Hotel Price: \$${selectedHotel!.price}'),
            ],
          ],
        ),
      ),
    );
  }
}
