import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static Color primaryColor = Colors.blue.shade500;
  static const double defaultBorderRadius = 12.0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  late final Hotel hotel;
  late final List<Map<String, dynamic>> selectedRooms;
  late final double totalPrice;
  late final DateTime CheckInDate;
  late final DateTime CheckOutDate;

  bool _isBookingInProgress = false;

  @override
  void initState() {
    super.initState();
    hotel = widget.bookingData.hotel;
    selectedRooms = widget.bookingData.selectedRooms;
    totalPrice = widget.bookingData.totalPrice;
    CheckInDate = widget.bookingData.checkInDate;
    CheckOutDate = widget.bookingData.checkOutDate;
  }

  Future<void> _saveHotelBookingToLocalStorage({String? debugId}) async {
    try {
      final String? userKey = await getUserSpecificKey('hotel_bookings');
      if (userKey == null) return;

      final prefs = await SharedPreferences.getInstance();
      final List<String> existingHotelBookingsJson =
          prefs.getStringList(userKey) ?? [];

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
      existingHotelBookingsJson.add(newHotelBookingJson);
      await prefs.setStringList(userKey, existingHotelBookingsJson);
    } catch (e) {
      _showSnackBar("Error saving hotel booking: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
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
            children: [
              _buildSectionCard(
                icon: Icons.hotel,
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
              _buildSectionCard(
                icon: Icons.person,
                title: "Your Information",
                child: Column(
                  children: [
                    _buildUserInfoField(
                      controller: _nameController,
                      labelText: "Full Name",
                      prefixIcon: Icons.person,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildUserInfoField(
                      controller: _emailController,
                      labelText: "Email Address",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter your email';
                        if (!RegExp(
                          r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$",
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
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your phone number'
                          : null,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String text = newValue.text.replaceAll(' ', '');
                          String newText = '';
                          for (int i = 0; i < text.length; i++) {
                            if (i % 4 == 0 && i != 0) newText += ' ';
                            newText += text[i];
                          }
                          return TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(
                              offset: newText.length,
                            ),
                          );
                        }),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter card number';
                        if (value.replaceAll(' ', '').length < 16) {
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'\d|/'),
                              ),
                              LengthLimitingTextInputFormatter(5),
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                String text = newValue.text;
                                if (text.length == 2 &&
                                    oldValue.text.length < text.length) {
                                  text += '/';
                                }
                                return TextEditingValue(
                                  text: text,
                                  selection: TextSelection.collapsed(
                                    offset: text.length,
                                  ),
                                );
                              }),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) return 'Enter expiry date';
                              if (!RegExp(
                                r'^(0[1-9]|1[0-2])\/\d{2}$',
                              ).hasMatch(value)) {
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
                              if (value!.isEmpty) return 'Enter CVV';
                              if (value.length != 3) {
                                return 'CVV must be 3 digits';
                              }
                              return null;
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(3),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildPaymentFormField(
                      controller: _cardHolderNameController,
                      labelText: "Cardholder Name",
                      prefixIcon: Icons.account_circle,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter cardholder name' : null,
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
                            final String debugId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            setState(() => _isBookingInProgress = true);

                            try {
                              for (var room in selectedRooms) {
                                await ApiService().bookRoom(
                                  id: hotel.id,
                                  roomType: room['type'],
                                  quantity: room['quantity'],
                                );
                              }

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

                              await _saveHotelBookingToLocalStorage(
                                debugId: debugId,
                              );

                              _showSnackBar(
                                "Booking confirmed for ${hotel.name} & saved",
                                isError: false,
                              );

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/BottomNavigationBar',
                                (route) => false,
                              );
                            } catch (error) {
                              _showSnackBar(
                                "Booking failed: $error",
                                isError: true,
                              );
                            } finally {
                              final hotelProvider = Provider.of<HotelProvider>(
                                context,
                                listen: false,
                              );
                              await hotelProvider.fetchHotels();
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
                    _isBookingInProgress ? "Processing..." : "Confirm Booking ",
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

  Widget _buildPaymentFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
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
