import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FlyHigh/screens/hotels/hotels_screen.dart';
import 'package:FlyHigh/models/flight.dart';

class FlightBookingScreen extends StatefulWidget {
  final Flight flight;

  const FlightBookingScreen({Key? key, required this.flight}) : super(key: key);

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  DateTime? departureDate;
  DateTime? returnDate;

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _returnController = TextEditingController();

  @override
  void dispose() {
    _departureController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return departureDate != null && returnDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;

    return Scaffold(
      appBar: AppBar(title: Text('${flight.from} → ${flight.to}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${flight.from} → ${flight.to}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${flight.price}',
                  style: const TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _departureController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Departure Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (pickedDate != null && pickedDate != departureDate) {
                      setState(() {
                        departureDate = pickedDate;
                        _departureController.text = pickedDate.toString().split(
                          ' ',
                        )[0];
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _returnController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Return Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    if (departureDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select departure date first."),
                        ),
                      );
                      return;
                    }

                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: departureDate!,
                      firstDate: departureDate!,
                      lastDate: DateTime(DateTime.now().year + 5),
                    );

                    if (pickedDate != null && pickedDate != returnDate) {
                      setState(() {
                        returnDate = pickedDate;
                        _returnController.text = pickedDate.toString().split(
                          ' ',
                        )[0];
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isFormValid()
                  ? () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                        'selected_flight',
                        json.encode({
                          'flight': flight.toJson(),
                          'departureDate': departureDate?.toIso8601String(),
                          'returnDate': returnDate?.toIso8601String(),
                        }),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelsScreen(city: flight.to),
                        ),
                      );
                    }
                  : null,
              child: const Text("Book Now"),
            ),

            if (!_isFormValid())
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  "Please select both departure and return dates.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
