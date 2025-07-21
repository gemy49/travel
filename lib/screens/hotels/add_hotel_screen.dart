import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../services/api_service.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({Key? key}) : super(key: key);

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Hotel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter city";
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Hotel Name"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter hotel name";
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
                controller: _roomsController,
                decoration: const InputDecoration(labelText: "Available Rooms"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Please enter available rooms";
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final hotel = Hotel(
                      id: DateTime.now().millisecondsSinceEpoch,
                      city: _cityController.text,
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      availableRooms: int.parse(_roomsController.text),
                    );

                    final api = ApiService();
                    await api.addHotel(hotel);

                    Navigator.pop(context);
                  }
                },
                child: const Text("Add Hotel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
