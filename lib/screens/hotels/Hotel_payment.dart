// lib/screens/hotels/hotel_payment_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:FlyHigh/models/hotel_booking_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/hotel.dart';
import '../../providers/hotel_provider.dart';
import '../../services/api_service.dart';
import '../../services/storage_keys.dart'; // Adjust path if needed

class HotelPaymentScreen extends StatefulWidget {
  final HotelBookingData bookingData;

  const HotelPaymentScreen({Key? key, required this.bookingData})
    : super(key: key);

  @override
  State<HotelPaymentScreen> createState() => _HotelPaymentScreenState();
}

class _HotelPaymentScreenState extends State<HotelPaymentScreen> {
  static Color primaryColor = Colors.blue.shade500; // Or Colors.blue.shade500;
  static const double defaultBorderRadius = 12.0;

  final _formKey = GlobalKey<FormState>();

  // --- User Information Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // --- Payment Information Controllers ---
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  // --- Data from bookingData ---
  late final Hotel hotel;
  late final List<Map<String, dynamic>> selectedRooms;
  late final double totalPrice;
  late final DateTime CheckInDate;
  late final DateTime CheckOutDate;

  bool _isBookingInProgress = false;
  @override
  void initState() {
    super.initState();
    // --- Initialize data from bookingData ---
    hotel = widget.bookingData.hotel;
    selectedRooms = widget.bookingData.selectedRooms;
    totalPrice = widget.bookingData.totalPrice;
    CheckInDate = widget.bookingData.checkInDate;
    CheckOutDate = widget.bookingData.checkOutDate;
  }

  // Modify the function signature to accept an optional debugId
  Future<void> _saveHotelBookingToLocalStorage({String? debugId}) async {
    print("Hotel Payment Save Function: Called with debug ID: $debugId");
    try {
      final String? userKey = await getUserSpecificKey('hotel_bookings');
      if (userKey == null) {
        print(
          "Hotel Payment Save Function: User key is null for debug ID: $debugId",
        );
        return; // Handle missing email
      }

      final prefs = await SharedPreferences.getInstance();
      final List<String> existingHotelBookingsJson =
          prefs.getStringList(userKey) ?? [];

      // Create hotel booking data map (as before)
      final Map<String, dynamic> hotelBookingDataMap = {
        'hotel': {
          'id': hotel.id,
          'city': hotel.city,
          'location': hotel.location,
          'name': hotel.name,
          'rate': hotel.rate,
          'image': hotel.image,
          'description': hotel.description,
        },
        'selectedRooms': selectedRooms,
        'totalPrice': totalPrice,
      };

      final String newHotelBookingJson = jsonEncode(hotelBookingDataMap);
      print(
        "Hotel Payment Save Function: Prepared JSON for debug ID: $debugId",
      );

      existingHotelBookingsJson.add(newHotelBookingJson);
      await prefs.setStringList(userKey, existingHotelBookingsJson);
      print(
        "Hotel Payment Save Function: Hotel booking saved successfully to key '$userKey' for debug ID: $debugId",
      );
    } catch (e) {
      print(
        "Hotel Payment Save Function: Error saving hotel booking for debug ID: $debugId, Error: $e",
      );
      // Optionally, show an error message to the user
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
        title: const Text("Hotel Booking & Payment"),
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
              // --- Hotel Booking Summary Section ---
              _buildSectionCard(
                icon: Icons.hotel, // Icon for hotel
                title: "Booking Summary",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHotelDetailRow(Icons.hotel, "Hotel", hotel.name),
                    _buildHotelDetailRow(
                      Icons.location_on,
                      "Location",
                      hotel.city,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Selected Rooms:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    ...selectedRooms.map((roomData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Text(
                              "${roomData['quantity']} x ${roomData['type']}",
                            ),
                            const Spacer(),
                            Text(
                              "\$${roomData['totalPriceForType'].toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(height: 20, thickness: 1),
                    _buildHotelDetailRow(
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

              // --- User Information Section ---
              _buildSectionCard(
                icon: Icons.person, // Icon for user
                title: "Your Information",
                child: Column(
                  children: [
                    _buildUserInfoField(
                      controller: _nameController,
                      labelText: "Full Name",
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildUserInfoField(
                      controller: _emailController,
                      labelText: "Email Address",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildUserInfoField(
                      controller: _phoneController,
                      labelText: "Phone Number",
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Payment Information Section (from your Flight_Payment example) ---
              _buildSectionCard(
                icon: Icons.credit_card, // Added icon
                title: "Payment Information",
                child: Column(
                  children: [
                    // Card Number
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

                    // Expiry Date & CVV Row
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
                            prefixIcon: Icons.lock, // Changed icon for security
                            keyboardType: TextInputType.number,
                            obscureText: true, // Keep obscuring CVV
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

                    // Cardholder Name
                    _buildPaymentFormField(
                      controller: _cardHolderNameController,
                      labelText: "Cardholder Name",
                      prefixIcon: Icons.account_circle,
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
              // Inside the build method, where the Confirm Booking & Pay ElevatedButton is:
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  // Disable the button if booking is in progress
                  onPressed: _isBookingInProgress
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final String debugId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            setState(() {
                              _isBookingInProgress = true;
                            });

                            try {
                              for (var room in selectedRooms) {
                                await ApiService().bookRoom(
                                  id: hotel.id,
                                  roomType: room['type'],
                                  quantity: room['quantity'],
                                );
                              }
                              // 1️⃣ احجز الغرف على السيرفر
                              await ApiService().addHotelBookingForUser(
                                bookingData: {
                                  "bookingId": DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  "hotelId": hotel.id,
                                  "hotelName": hotel.name,
                                  "city": hotel.city,
                                  "rooms": selectedRooms
                                      .map(
                                        (room) => {
                                          "type": room['type'],
                                          "count": room['quantity'],
                                        },
                                      )
                                      .toList(),
                                  "totalCost": totalPrice,
                                  "fullName": _nameController.text.trim(),
                                  "phone": _phoneController.text.trim(),
                                  "bookingDate": DateTime.now()
                                      .toIso8601String(),
                                  "checkIn": CheckInDate.toString(),
                                  "checkOut": CheckOutDate.toString(),
                                },
                              );

                              // 3️⃣ خزّن نسخة محليًا
                              await _saveHotelBookingToLocalStorage(
                                debugId: debugId,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "✅ Booking confirmed for ${hotel.name} & saved",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/BottomNavigationBar',
                                (route) => false,
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("❌ Booking failed: $error"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              final hotelProvider = Provider.of<HotelProvider>(
                                context,
                                listen: false,
                              );
                              await hotelProvider.fetchHotels();

                              setState(() {
                                _isBookingInProgress = false;
                              });
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
                    _isBookingInProgress ? "Processing..." : "Confirm Booking ",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4, // Subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // More padding inside
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header Row
            Row(
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ), // Icon with color and size
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
            const SizedBox(height: 15), // Space below header
            child, // The content passed to the card
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Builds a styled row for hotel details ---
  Widget _buildHotelDetailRow(
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
          Icon(icon, color: primaryColor, size: 20), // Consistent icon
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
              color: isTotal
                  ? primaryColor
                  : Colors.black87, // Highlight total price
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Builds a styled TextFormField for user details ---
  Widget _buildUserInfoField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
          color: primaryColor,
        ), // Colored prefix icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2.0,
          ), // Highlight on focus
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ), // Better padding
      ),
      validator: validator,
    );
  }

  // --- Helper Widget: Builds a styled TextFormField for payment details (from Flight_Payment example) ---
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
        prefixIcon: Icon(
          prefixIcon,
          color: primaryColor,
        ), // Colored prefix icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2.0,
          ), // Highlight on focus
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ), // Better padding
      ),
      validator: validator,
    );
  }
}
