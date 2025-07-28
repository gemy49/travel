import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Flights_booking_data.dart';
import '../../services/storage_keys.dart'; // تأكد من صحة مسار الاستيراد

class Flight_Payment extends StatefulWidget {
  final FlightBookingData bookingData;

  const Flight_Payment({Key? key, required this.bookingData}) : super(key: key);

  @override
  State<Flight_Payment> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<Flight_Payment> {
  static  Color primaryColor = Colors.blue.shade500;
  static const double defaultBorderRadius = 12.0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderNameController = TextEditingController();

  // --- Add variables to hold data from bookingData ---
  late final Flight flight;
  late final int numberOfAdults;
  late final int numberOfChildren;
  late final int numberOfSeats;
  late final double totalPrice;
  bool _isBookingInProgress = false;
  // Modify the function signature to accept an optional debugId
  Future<void> _saveBookingToLocalStorage({String? debugId}) async {
    print("Flight Payment Save Function: Called with debug ID: $debugId");
    try {
      final String? userKey = await getUserSpecificKey('flight_bookings');
      if (userKey == null) {
        print("Flight Payment Save Function: User key is null for debug ID: $debugId");
        return; // Handle missing email
      }

      final prefs = await SharedPreferences.getInstance();
      final List<String> existingBookingsJson = prefs.getStringList(userKey) ?? [];

      // Create booking data map (as before)
      final Map<String, dynamic> bookingDataMap = {
        'flight': {
          'id': flight.id,
          'from': flight.from,
          'to': flight.to,
          'date': flight.date,
          'returnDate': flight.returnDate,
          'departureTime': flight.departureTime,
          'arrivalTime': flight.arrivalTime,
          'price': flight.price,
          'airline': flight.airline,
        },
        'numberOfAdults': numberOfAdults,
        'numberOfChildren': numberOfChildren,
        'totalPrice': totalPrice,
      };

      final String newBookingJson = jsonEncode(bookingDataMap);
      print("Flight Payment Save Function: Prepared JSON for debug ID: $debugId");

      existingBookingsJson.add(newBookingJson);
      await prefs.setStringList(userKey, existingBookingsJson);
      print("Flight Payment Save Function: Booking saved successfully to key '$userKey' for debug ID: $debugId");
    } catch (e) {
      print("Flight Payment Save Function: Error saving booking for debug ID: $debugId, Error: $e");
      // Optionally, show an error message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    // --- Initialize data from bookingData ---
    flight = widget.bookingData.flight;
    numberOfAdults = widget.bookingData.numberOfAdults;
    numberOfChildren = widget.bookingData.numberOfChildren;
    totalPrice = (flight.price * numberOfAdults)+(flight.price * (numberOfChildren*.5));
    numberOfSeats=numberOfAdults+numberOfChildren;
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
    final theme = Theme.of(context);

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
              // --- Flight Summary Section with Icon ---
              _buildSectionCard(
                icon: Icons.flight,
                title: "Flight Summary",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFlightDetailRow(Icons.flight_takeoff, "From", flight.from),
                    _buildFlightDetailRow(Icons.flight_land, "To", flight.to),
                    _buildFlightDetailRow(Icons.calendar_today, "Departure", "${flight.date} "),
                    _buildFlightDetailRow(Icons.calendar_today, "Return", "${flight.returnDate} "),
                    _buildFlightDetailRow(Icons.access_time, "Departure Time", "${flight.departureTime} "),
                    _buildFlightDetailRow(Icons.access_time, "Arrival Time", "${flight.arrivalTime} "),
                    _buildFlightDetailRow(Icons.airline_seat_recline_normal, "Seats", numberOfSeats.toString()),
                    _buildFlightDetailRow(Icons.airlines, "Airline", flight.airline),
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

              // --- Payment Information Section with Icon ---
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
                        if (value == null || value.isEmpty) {
                          return 'Enter card number';
                        } else if (value.length < 16) {
                          return 'Card number must be 16 digits';
                        }
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
                              if (value == null || value.isEmpty) {
                                return 'Enter expiry date';
                              }
                              final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                              if (!regex.hasMatch(value)) {
                                return 'Invalid format (MM/YY)';
                              }
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
                              if (value == null || value.isEmpty) {
                                return 'Enter CVV';
                              } else if (value.length != 3) {
                                return 'CVV must be 3 digits';
                              }
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
                        if (value == null || value.isEmpty) {
                          return 'Enter cardholder name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- Confirm Payment Button ---
              // Inside the build method, where the Confirm Payment ElevatedButton is:
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  // Disable the button if booking is in progress
                   onPressed: _isBookingInProgress
                    ? null
                    : () {
              if (_formKey.currentState!.validate()) {
              // --- ADD THIS DEBUGGING LINE ---
              final String debugId = DateTime.now().millisecondsSinceEpoch.toString();
              print("Flight Payment: Initiating save with debug ID: $debugId");
              // --- END ADDITION ---

              setState(() {
                        _isBookingInProgress = true;
                      });

                      // --- Simulate Payment Processing & Save ---
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Processing payment and saving booking..."),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Call the save function
              _saveBookingToLocalStorage(debugId: debugId).then((_) { // Modify function signature if passing ID
                print("Flight Payment: Save completed for debug ID: $debugId");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Payment confirmed & booking saved!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // --- Clear Form Fields ---
                        // ... (clear controllers and reset form) ...

                        // --- Navigate after saving ---
                        // Example: Navigate to the My Flights screen
                        Navigator.pushReplacementNamed(context, '/BottomNavigationBar');
                        // Or pop back:
                        // Navigator.of(context).pop(); // Pop Flight_Payment
                        // Navigator.of(context).pop(); // Pop FlightDetailsScreen

                      }).catchError((error) {
                print("Flight Payment: Save failed for debug ID: $debugId, Error: $error");                        print("Failed to save flight booking: $error");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Booking confirmed, but failed to save locally: $error"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        // Consider navigation even if saving failed?
                        // Navigator.pushNamedAndRemoveUntil(context, '/my-flights', (route) => false);

                      }).whenComplete(() {
                print("Flight Payment: Save operation finished (success/fail) for debug ID: $debugId");
                        // This ensures the button is re-enabled whether it succeeded or failed
                        if (mounted) { // Check if the widget is still in the tree
                          setState(() {
                            _isBookingInProgress = false;
                          });
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // Optional: Change button appearance when disabled
                    // backgroundColor: _isBookingInProgress ? Colors.grey : primaryColor,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    _isBookingInProgress ? "Processing..." : "Confirm Payment",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
// ... rest of the widget tree ...
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Builds a styled section card with an icon ---
  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
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

  // --- Helper Widget: Builds a styled row for flight details ---
  Widget _buildFlightDetailRow(IconData icon, String label, String value, {bool isBold = false, bool isTotal = false}) {
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

  // --- Helper Widget: Builds a styled TextFormField for payment details ---
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
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
      ),
      validator: validator,
    );
  }
}