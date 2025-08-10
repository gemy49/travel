import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Flights_booking_data.dart';
import '../../services/api_service.dart';
import '../../services/storage_keys.dart';

class Flight_Payment extends StatefulWidget {
  final FlightBookingData bookingData;

  const Flight_Payment({Key? key, required this.bookingData}) : super(key: key);

  @override
  State<Flight_Payment> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<Flight_Payment> {
  static Color primaryColor = Colors.blue.shade500;
  static const double defaultBorderRadius = 12.0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  late final Flight flight;
  late final int numberOfAdults;
  late final int numberOfChildren;
  late final int numberOfSeats;
  late final double totalPrice;
  bool _isBookingInProgress = false;

  @override
  void initState() {
    super.initState();
    flight = widget.bookingData.flight;
    numberOfAdults = widget.bookingData.numberOfAdults;
    numberOfChildren = widget.bookingData.numberOfChildren;
    totalPrice =
        (flight.price * numberOfAdults) +
        (flight.price * (numberOfChildren * .5));
    numberOfSeats = numberOfAdults + numberOfChildren;
  }

  Future<void> _saveBookingToLocalStorage(Map<String, dynamic> booking) async {
    try {
      final String? userKey = await getUserSpecificKey('bookedFlights');
      if (userKey == null) return;

      final prefs = await SharedPreferences.getInstance();
      final List<String> existingBookings = prefs.getStringList(userKey) ?? [];

      existingBookings.add(jsonEncode(booking));
      await prefs.setStringList(userKey, existingBookings);

      print("Flight booking saved locally under key: $userKey");
    } catch (e) {
      print("Error saving booking locally: $e");
    }
  }

  Future<void> _saveBookingToServer(Map<String, dynamic> booking) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      if (email == null || email.isEmpty) {
        print("No email found for booking");
        return;
      }

      await ApiService().bookFlight(
        bookingData: {
          "flightId": flight.id, // ID من الـ Flight نفسه
          "adults": numberOfAdults,
          "children": numberOfChildren,
        },
      );
      print("Flight booking sent to server successfully");
    } catch (e) {
      print("Error saving booking to server: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flight And Payment"),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                icon: Icons.flight,
                title: "Flight Summary",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFlightDetailRow(
                      Icons.flight_takeoff,
                      "From",
                      flight.from,
                    ),
                    _buildFlightDetailRow(Icons.flight_land, "To", flight.to),
                    _buildFlightDetailRow(
                      Icons.calendar_today,
                      "Departure",
                      flight.date,
                    ),
                    _buildFlightDetailRow(
                      Icons.access_time,
                      "Departure Time",
                      flight.departureTime,
                    ),
                    _buildFlightDetailRow(
                      Icons.access_time,
                      "Arrival Time",
                      flight.arrivalTime,
                    ),
                    _buildFlightDetailRow(
                      Icons.airline_seat_recline_normal,
                      "Seats",
                      numberOfSeats.toString(),
                    ),
                    _buildFlightDetailRow(
                      Icons.airlines,
                      "Airline",
                      flight.airline,
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildFlightDetailRow(
                      Icons.attach_money,
                      "Base Price",
                      "\$${flight.price.toStringAsFixed(2)}",
                      isBold: true,
                    ),
                    _buildFlightDetailRow(
                      Icons.confirmation_number,
                      "Total Price",
                      "\$${totalPrice.toStringAsFixed(2)}",
                      isBold: true,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionCard(
                icon: Icons.credit_card,
                title: "Payment Information",
                child: Column(
                  children: [
                    _buildPaymentFormField(
                      controller: _cardNumberController,
                      labelText: "Card Number",
                      prefixIcon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter card number';
                        if (value.length < 16)
                          return 'Card number must be 16 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentFormField(
                            controller: _expiryDateController,
                            labelText: "MM/YY",
                            prefixIcon: Icons.date_range,
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Enter expiry date';
                              final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                              if (!regex.hasMatch(value))
                                return 'Invalid format (MM/YY)';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildPaymentFormField(
                            controller: _cvvController,
                            labelText: "CVV",
                            prefixIcon: Icons.lock,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Enter CVV';
                              if (value.length != 3)
                                return 'CVV must be 3 digits';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildPaymentFormField(
                      controller: _cardHolderNameController,
                      labelText: "Cardholder Name",
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter cardholder name';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isBookingInProgress
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final String flightId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();

                            final bookingData = {
                              "flightId": flightId,
                              "id": flight.id,
                              "from": flight.from,
                              "to": flight.to,
                              "date": flight.date,
                              "departureTime": flight.departureTime,
                              "arrivalTime": flight.arrivalTime,
                              "price": flight.price,
                              "airline": flight.airline,
                              "adults": numberOfAdults,
                              "children": numberOfChildren,
                            };

                            setState(() => _isBookingInProgress = true);

                            try {
                              await _saveBookingToServer(bookingData);
                              await _saveBookingToLocalStorage(bookingData);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Flight booked successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pushReplacementNamed(
                                context,
                                '/BottomNavigationBar',
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("❌ Booking failed: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() => _isBookingInProgress = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                    ),
                    elevation: 3,
                  ),
                  icon: _isBookingInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    _isBookingInProgress ? "Processing..." : "Confirm Payment",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ),
      ),
      validator: validator,
    );
  }
}
