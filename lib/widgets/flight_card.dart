import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback onDetailsPressed;

  const FlightCard({
    Key? key,
    required this.flight,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(child: Text(flight.airline[0])),
        title: Text('${flight.from} → ${flight.to}'),
        subtitle: Text('Date: ${flight.date}, Price: \$${flight.price}'),
        trailing: ElevatedButton(
          onPressed: onDetailsPressed,
          child: const Text("Details"),
        ),
      ),
    );
  }
}
