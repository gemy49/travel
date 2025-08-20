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

  // Controllers for credit card information
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderNameController =
  TextEditingController();

  late final Hotel hotel;
  late final List<Map<String, dynamic>> selectedRooms;
  late final double totalPrice;
  late final DateTime checkInDate;
  late final DateTime checkOutDate;

  bool _isBookingInProgress = false;

  @override
  void initState() {
    super.initState();
    hotel = widget.bookingData.hotel;
    selectedRooms = widget.bookingData.selectedRooms;
    totalPrice = widget.bookingData.totalPrice;
    checkInDate = widget.bookingData.checkInDate;
    checkOutDate = widget.bookingData.checkOutDate;
  }

  Future<void> _saveHotelBookingToLocalStorage({String? debugId}) async {
    try {
      // Get the user-specific key for hotel bookings
      final String? userKey = await getUserSpecificKey('hotel_bookings');
      if (userKey == null) {
        print("HotelPaymentScreen: User key is null, cannot save booking.");
        return; // Or handle the error appropriately
      }

      final prefs = await SharedPreferences.getInstance();

      // Retrieve existing bookings for this user
      final List<String> existingHotelBookingsJson =
          prefs.getStringList(userKey) ?? [];

      // Create a map representing the booking data
      // Ensure only serializable types (like primitives, Lists, Maps) are used
      final Map<String, dynamic> hotelBookingDataMap = {
        'hotel': {
          'id': hotel.id,
          'city': hotel.city,
          'location': hotel.location,
          'name': hotel.name,
          'rate': hotel.rate,
          'image': hotel.image,
          'description': hotel.description,
          // Add other necessary hotel fields if needed, ensuring they are serializable
        },
        'selectedRooms': selectedRooms,
        'totalPrice': totalPrice,
        'checkInDate': checkInDate.toIso8601String(), // Convert DateTime to String
        'checkOutDate': checkOutDate.toIso8601String(), // Convert DateTime to String
        // Add a timestamp or debugId for uniqueness if needed
        'bookingTimestamp': DateTime.now().toIso8601String(),
        if (debugId != null) 'debugId': debugId,
      };

      // Encode the map to a JSON string
      final String newHotelBookingJson = jsonEncode(hotelBookingDataMap);

      // Add the new booking JSON string to the list
      existingHotelBookingsJson.add(newHotelBookingJson);

      // Save the updated list back to SharedPreferences
      await prefs.setStringList(userKey, existingHotelBookingsJson);
      print("HotelPaymentScreen: Booking saved to local storage with key: $userKey");
    } catch (e, s) {
      print("HotelPaymentScreen: Error saving hotel booking to local storage: $e\nStack: $s");
      _showSnackBar("Error saving hotel booking: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; // Check if the widget is still in the tree
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
                    _buildHotelDetailRow(
                      Icons.calendar_today,
                      "Check-in",
                      "${checkInDate.day}/${checkInDate.month}/${checkInDate.year}",
                    ),
                    _buildHotelDetailRow(
                      Icons.calendar_today_outlined,
                      "Check-out",
                      "${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}",
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Selected Rooms:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    ...selectedRooms.map((roomData) {
                      // Ensure keys exist in roomData
                      final type = roomData['type'] ?? 'Unknown Room';
                      final quantity = roomData['quantity'] ?? 0;

                      final totalPriceForType = roomData['totalPriceForType'] ??
                          (roomData['pricePerNight'] ?? 0) * quantity;
                      final nights = checkOutDate.difference(checkInDate).inDays;
                      final pricePerNight =
                      nights > 0 ? totalPriceForType / quantity / nights : 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$quantity x $type",
                                ),
                                const Spacer(),
                                Text(
                                  "\$${totalPriceForType.toStringAsFixed(2)}",
                                ),
                              ],
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
                      value!.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildUserInfoField(
                      controller: _emailController,
                      labelText: "Email Address",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final trimmedValue = value!.trim();
                        if (trimmedValue.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$",
                        ).hasMatch(trimmedValue)) {
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
                      validator: (value) => value!.trim().isEmpty
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
                          if (text.length > 16) text = text.substring(0, 16);
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
                        final cleanedValue =
                        value!.replaceAll(RegExp(r'\s+'), '');
                        if (cleanedValue.isEmpty) return 'Enter card number';
                        if (cleanedValue.length != 16) {
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
                                // Prevent adding more than one slash
                                if (text.length == 2 &&
                                    oldValue.text.length < text.length &&
                                    !text.contains('/')) {
                                  text += '/';
                                }
                                // Ensure only one slash and correct format
                                if (text.length > 5) {
                                  text = text.substring(0, 5);
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
                              // Optional: Check if the date is not in the past
                              // This requires parsing the MM/YY string
                              try {
                                final parts = value.split('/');
                                final month = int.parse(parts[0]);
                                final year = int.parse(parts[1]);
                                final now = DateTime.now();
                                // Assuming YY is for 20XX if YY > current year % 100, else 21XX?
                                // Let's assume 20XX for simplicity, adjust as needed.
                                final fullYear = 2000 + year;
                                if (fullYear < now.year ||
                                    (fullYear == now.year &&
                                        month < now.month)) {
                                  return 'Card is expired';
                                }
                              } catch (e) {
                                // If parsing fails, let the format validation handle it
                                // or return a generic error if preferred.
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
                              if (value.length != 3 &&
                                  value.length != 3) { // Some cards have 4 digit CVV
                                return 'CVV must be 3 or 4 digits';
                              }
                              if (!RegExp(r'^\d+$').hasMatch(value)) {
                                return 'CVV must be numeric';
                              }
                              return null;
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(3), // Allow up to 4
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
                      validator: (value) => value!.trim().isEmpty
                          ? 'Enter cardholder name'
                          : null,
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
                        // 1. Book rooms via API
                        for (var room in selectedRooms) {
                          final roomType = room['type'] as String;
                          final quantity = room['quantity'] as int;
                          print(
                              "HotelPaymentScreen: Attempting to book $quantity of $roomType for hotel ID ${hotel.id}");
                          await ApiService().bookRoom(
                            id: hotel.id,
                            roomType: roomType,
                            quantity: quantity,
                          );
                          print(
                              "HotelPaymentScreen: Successfully booked $quantity of $roomType");
                        }

                        // 2. Add hotel booking record for the user via API
                        final bookingDataForApi = {
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
                          "email": _emailController.text.trim(),
                          "bookingDate": DateTime.now().toIso8601String(),
                          "checkIn":
                          checkInDate.toIso8601String(), // Use correct variable
                          "checkOut":
                          checkOutDate.toIso8601String(), // Use correct variable
                        };
                        print(
                            "HotelPaymentScreen: Sending booking data to API: $bookingDataForApi");
                        await ApiService()
                            .addHotelBookingForUser(
                            bookingData: bookingDataForApi);
                        print(
                            "HotelPaymentScreen: Successfully added booking record via API");

                        // 3. Save booking to local storage
                        await _saveHotelBookingToLocalStorage(
                          debugId: debugId,
                        );

                        // 4. Show success message
                        _showSnackBar(
                          "Booking confirmed for ${hotel.name} & saved locally!",
                          isError: false,
                        );

                        // 5. Navigate to a success screen or back to main
                        // Using pushNamedAndRemoveUntil to clear the booking/payment stack
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/BottomNavigationBar', // Ensure this route exists
                                (route) => false, // Remove all previous routes
                          );
                        }
                      } catch (error, stackTrace) {
                        print(
                            "HotelPaymentScreen: Booking process failed: $error\nStack Trace: $stackTrace");
                        if (context.mounted) {
                          _showSnackBar(
                            "Booking failed: ${error.toString().contains('SocketException') || error.toString().contains('HandshakeException') ? 'Network error. Please check your connection.' : error.toString()}",
                            isError: true,
                          );
                        }
                      } finally {
                        // Refresh hotel data (e.g., available rooms) - optional but good practice
                        try {
                          final hotelProvider =
                          Provider.of<HotelProvider>(
                            context,
                            listen: false,
                          );
                          await hotelProvider.fetchHotels();
                          print(
                              "HotelPaymentScreen: Hotel data refreshed after booking attempt.");
                        } catch (refreshError) {
                          print(
                              "HotelPaymentScreen: Failed to refresh hotel data: $refreshError");
                        }
                        // Re-enable the button
                        if (mounted) {
                          setState(() => _isBookingInProgress = false);
                        }
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0), // Add padding
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
                    _isBookingInProgress ? "Processing..." : "Confirm Booking",
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