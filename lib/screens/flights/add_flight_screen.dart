import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/flight.dart';
import '../../services/api_service.dart';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({Key? key}) : super(key: key);

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _arrivalTimeController = TextEditingController();
  final _priceController = TextEditingController();
  final _airlineController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _priceController.dispose();
    _airlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Flight")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fromController,
                decoration: const InputDecoration(labelText: "From"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter departure city";
                  return null;
                },
              ),
              TextFormField(
                controller: _toController,
                decoration: const InputDecoration(labelText: "To"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter destination city";
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter date";
                  return null;
                },
              ),
              TextFormField(
                controller: _departureTimeController,
                decoration: const InputDecoration(labelText: "Departure Time"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter departure time";
                  return null;
                },
              ),
              TextFormField(
                controller: _arrivalTimeController,
                decoration: const InputDecoration(labelText: "Arrival Time"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter arrival time";
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter price";
                  return null;
                },
              ),
              TextFormField(
                controller: _airlineController,
                decoration: const InputDecoration(labelText: "Airline"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter airline";
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final flight = Flight(
                      id: DateTime.now().millisecondsSinceEpoch,
                      from: _fromController.text,
                      to: _toController.text,
                      date: _dateController.text,
                      departureTime: _departureTimeController.text,
                      arrivalTime: _arrivalTimeController.text,
                      price: double.parse(_priceController.text),
                      airline: _airlineController.text,
                    );

                    final api = ApiService();
                    await api.addFlight(flight);

                    Navigator.pop(context);
                  }
                },
                child: const Text("Add Flight"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
