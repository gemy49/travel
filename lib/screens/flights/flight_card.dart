import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../providers/counter_bloc.dart';

class FlightCard extends StatefulWidget {
  final Flight flight;

   FlightCard({
    Key? key,
    required this.flight,
  }) : super(key: key);

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CounterBloc>();
    bool love = cubit.state.favoriteIds.contains(widget.flight.id); // حالة القلب
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                widget.flight.airline[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.flight.from} → ${widget.flight.to}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${widget.flight.date}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Return: ${widget.flight.returnDate}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Price: \$${widget.flight.price}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                cubit.toggleFavorite(widget.flight.id);
                setState(() {});
              },
              icon: Icon(
                love ? Icons.favorite : Icons.favorite_border,
                color: love ? Colors.blue : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
