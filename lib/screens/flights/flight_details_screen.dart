import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';
import 'package:provider/provider.dart';
import '../../models/Flights_booking_data.dart';
import '../../providers/place_provider.dart';
import '../../providers/weather_provider.dart';

// If FlightBookingData is defined here (not recommended), remove it and use the import above.

class FlightDetailsScreen extends StatefulWidget {
  final Flight flight;

  const FlightDetailsScreen({Key? key, required this.flight}) : super(key: key);

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  late Future<void> _placesFuture;

  // --- Update state variables ---
  int _numberOfAdults = 1; // Default to 1 adult
  int _numberOfChildren = 0; // Default to 0 children

  @override
  void initState() {
    super.initState();
    _placesFuture = Provider.of<PlaceProvider>(context, listen: false)
        .fetchPlaces(city: widget.flight.to);
    Provider.of<WeatherProvider>(context, listen: false)
        .fetchWeather(city: widget.flight.to);
  }

  // --- Function to calculate total price ---
  double _calculateTotalPrice() {
    double adultCost = widget.flight.price * _numberOfAdults;
    double childCost = (widget.flight.price * 0.5) * _numberOfChildren; // Half price for children
    return adultCost + childCost;
  }

  // --- Function to handle booking - updated to pass data ---
  void _handleBooking(BuildContext context) {
    // Ensure at least one passenger is selected
    if (_numberOfAdults + _numberOfChildren <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one passenger."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create an object to hold flight and passenger count
    final bookingData = FlightBookingData(
      flight: widget.flight,
      numberOfAdults: _numberOfAdults,
      numberOfChildren: _numberOfChildren,
    );
    // Navigate to the payment screen, passing the booking data
    Navigator.pushNamed(context, '/Flight_Payment', arguments: bookingData);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Color primaryColor = Colors.blue.shade500; // Define primary color
    // --- Calculate total price ---
    final double totalPrice = _calculateTotalPrice(); // Use the new function

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5), // Consistent background
      body: Container(
        height: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.04,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- Flight Details Card with Book Button ---
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Flight Details Title
                          Text(
                            "Flight Details",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                          const SizedBox(height: 12),
                          // Flight Info Rows - Updated to match data fields
                          _infoRow(Icons.flight_takeoff, 'From',
                              widget.flight.from, primaryColor),
                          _infoRow(Icons.flight_land, 'To', widget.flight.to, primaryColor),
                          _infoRow(Icons.date_range, 'Departure Date', widget.flight.date, primaryColor),
                          _infoRow(Icons.access_time, 'Departure Time', widget.flight.departureTime, primaryColor),
                          _infoRow(Icons.access_time, 'Arrival Time', widget.flight.arrivalTime, primaryColor),
                          _infoRow(Icons.monetization_on, 'Base Price (Adult)', '\$${widget.flight.price}', primaryColor), // Clarify adult price
                          _infoRow(Icons.monetization_on, 'Base Price (Child)', '\$${(widget.flight.price * 0.5).toStringAsFixed(2)}', primaryColor), // Show child price
                          _infoRow(Icons.airlines, 'Airline', widget.flight.airline, primaryColor),
                          // Removed transit section as it's not in the provided data sample

                          const SizedBox(height: 15),
                          // --- Passenger Selection (Adults and Children) ---
                          _buildPassengerSelection(primaryColor), // Add the new UI

                          const SizedBox(height: 10),
                          // --- Updated Total Price Display ---
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Price:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  '\$${totalPrice.toStringAsFixed(2)}', // Display calculated total price
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),
                          // --- Book Now Button ---
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withOpacity(0.7)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _handleBooking(context), // Call updated handler
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Weather Section ---
                  // ... (rest of the Weather Section code remains largely the same, just update variable names if needed) ...
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Weather Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "The next three days weather",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Text("in (${widget.flight.to})",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                            softWrap: true,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 15),
                        // Weather Forecast
                        Consumer<WeatherProvider>(
                          builder: (context, weatherProvider, _) {
                            if (weatherProvider.isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final forecastDays =
                                weatherProvider.weather?.forecast.forecastday;
                            if (forecastDays == null ||
                                forecastDays.isEmpty) {
                              return const Text("Weather data not available");
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: forecastDays.map((day) {
                                  return Container(
                                    width: 180, // Slightly reduced width
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Card(
                                      // Use primary color for card
                                      color: primaryColor.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              "https:${day.conditionIcon}",
                                              width: 50,
                                              height: 50,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${day.date}",
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${day.conditionText}",
                                              style: const TextStyle(
                                                  color: Colors.black87),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              "High: ${day.maxTempC}°C",
                                              style: const TextStyle(
                                                  color: Colors.black87),
                                            ),
                                            Text(
                                              "Low: ${day.minTempC}°C",
                                              style: const TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Famous Places Section ---
                  // ... (rest of the Famous Places Section code remains largely the same) ...
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Places Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              "Famous Places",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Places List
                        FutureBuilder(
                          future: _placesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              final places =
                                  Provider.of<PlaceProvider>(context).places;
                              if (places.isEmpty) {
                                return const Center(
                                    child: Text("No places found"));
                              }
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: places.length,
                                itemBuilder: (context, index) {
                                  final place = places[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                            child: Image.asset(
                                              "assets/places/${place.image}",
                                              width: double.infinity,
                                              height: 180, // Slightly reduced height
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              place.name,
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Add the passenger selection UI builder method ---
  Widget _buildPassengerSelection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Passengers:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        // Adults Selector
        _buildPassengerTypeSelector(
          label: 'Adults',
          count: _numberOfAdults,
          onIncrement: () {
            setState(() {
              // Optional: Set a maximum limit
              // if (_numberOfAdults + _numberOfChildren < 10) {
              _numberOfAdults++;
              // }
            });
          },
          onDecrement: () {
            setState(() {
              if (_numberOfAdults > 0) { // Allow 0 adults if children are selected?
                // Ensure at least one passenger total?
                // if (_numberOfAdults > 1 || _numberOfChildren > 0) {
                _numberOfAdults--;
                // }
              }
            });
          },
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 8),
        // Children Selector
        _buildPassengerTypeSelector(
          label: 'Children',
          count: _numberOfChildren,
          onIncrement: () {
            setState(() {
              // Optional: Set a maximum limit
              // if (_numberOfAdults + _numberOfChildren < 10) {
              _numberOfChildren++;
              // }
            });
          },
          onDecrement: () {
            setState(() {
              if (_numberOfChildren > 0) {
                _numberOfChildren--;
              }
            });
          },
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  // Helper widget for selecting adults or children
  Widget _buildPassengerTypeSelector({
    required String label,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Color primaryColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            // Minus Button
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: primaryColor),
              onPressed: onDecrement,
            ),
            // Number Display
            Container(
              width: 40, // Fixed width for consistent display
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Plus Button
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: primaryColor),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }


  // Updated _infoRow to accept primaryColor (remains unchanged)
  Widget _infoRow(IconData icon, String label, String value, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}