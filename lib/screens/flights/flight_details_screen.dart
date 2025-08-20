import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';
import 'package:provider/provider.dart';
import '../../models/Flights_booking_data.dart';
import '../../providers/place_provider.dart';
import '../../providers/weather_provider.dart';

class FlightDetailsScreen extends StatefulWidget {
  final Flight? flight;
  final Map<String, dynamic>? chat;

  const FlightDetailsScreen({Key? key, this.flight, this.chat}) : super(key: key);

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  late Future<void> _placesFuture;
  // Local Flight object to hold data from either widget.flight or widget.chat
  Flight? _localFlight;

  // --- Update state variables ---
  int _numberOfAdults = 1;
  int _numberOfChildren = 0;

  @override
  void initState() {
    super.initState();

    // Determine the flight data source
    if (widget.flight != null) {
      _localFlight = widget.flight;
    } else if (widget.chat != null) {
      // Attempt to create a Flight object from chat data
      // You'll need to adjust these keys based on the actual structure of your chat['flights'] item
      try {
        _localFlight = Flight(
          // Assuming your Flight constructor takes named parameters like this:
          // You might need to parse strings to appropriate types (e.g., int.parse, double.parse)
          id: int.tryParse(widget.chat!['id']?.toString() ?? '') ?? 0,
          from: widget.chat!['from']?.toString() ?? 'Unknown Origin',
          to: widget.chat!['to']?.toString() ?? 'Unknown Destination',
          date: widget.chat!['date']?.toString() ?? 'Unknown Date',
          departureTime: widget.chat!['departureTime']?.toString() ?? 'Unknown Departure Time',
          arrivalTime: widget.chat!['arrivalTime']?.toString() ?? 'Unknown Arrival Time',
          price: widget.chat!['price'] is num ? widget.chat!['price'].toDouble() : 0.0, // Handle potential int/double
          airline: widget.chat!['airline']?.toString() ?? 'Unknown Airline',
          // Add other fields if necessary, providing defaults
        );
        // Debug print
        print("Flight data extracted from chat: ${_localFlight!.to}");
      } catch (e) {
        // Handle potential errors in creating Flight object from chat data
        print("Error creating Flight from chat data: $e");
        _localFlight = null; // Indicate failure to create local flight data
      }
    }

    // Fetch data only if we have flight information
    if (_localFlight != null) {
      _placesFuture = Provider.of<PlaceProvider>(context, listen: false)
          .fetchPlaces(city: _localFlight!.to);
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeather(city: _localFlight!.to);
    } else {
      // Initialize _placesFuture to a completed future to avoid errors if _localFlight is null
      _placesFuture = Future.value();
      // Show an error message or handle the null case in build()
      print("Flight data is missing (both flight and chat).");
    }
  }

  // --- Function to calculate total price ---
  double _calculateTotalPrice() {
    // Use _localFlight
    if (_localFlight == null) return 0.0;
    double adultCost = _localFlight!.price * _numberOfAdults;
    double childCost = (_localFlight!.price * 0.5) * _numberOfChildren;
    return adultCost + childCost;
  }

  // --- Function to handle booking - updated to pass data ---
  void _handleBooking(BuildContext context) {
    // Use _localFlight
    if (_localFlight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Flight details are missing."), backgroundColor: Colors.red),
      );
      return;
    }
    if (_numberOfAdults + _numberOfChildren <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one passenger."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Pass _localFlight
    final bookingData = FlightBookingData(
      flight: _localFlight!,
      numberOfAdults: _numberOfAdults,
      numberOfChildren: _numberOfChildren,
    );
    Navigator.pushNamed(context, '/Flight_Payment', arguments: bookingData);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Color primaryColor = Colors.blue.shade500;

    // Check if we have valid flight data to display
    if (_localFlight == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flight Details')),
        body: const Center(
          child: Text('Flight information is not available.'),
        ),
      );
    }

    final double totalPrice = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
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
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Flight Details",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                          const SizedBox(height: 12),
                          // Use _localFlight for displaying details
                          _infoRow(Icons.flight_takeoff, 'From',
                              _localFlight!.from, primaryColor),
                          _infoRow(Icons.flight_land, 'To', _localFlight!.to, primaryColor),
                          _infoRow(Icons.date_range, 'Departure Date', _localFlight!.date, primaryColor),
                          _infoRow(Icons.access_time, 'Departure Time', _localFlight!.departureTime, primaryColor),
                          _infoRow(Icons.access_time, 'Arrival Time', _localFlight!.arrivalTime, primaryColor),
                          _infoRow(Icons.monetization_on, 'Base Price (Adult)', '\$${_localFlight!.price.toStringAsFixed(2)}', primaryColor),
                          _infoRow(Icons.monetization_on, 'Base Price (Child)', '\$${(_localFlight!.price * 0.5).toStringAsFixed(2)}', primaryColor),
                          _infoRow(Icons.airlines, 'Airline', _localFlight!.airline, primaryColor),

                          const SizedBox(height: 15),
                          _buildPassengerSelection(primaryColor),

                          const SizedBox(height: 10),
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
                                  '\$${totalPrice.toStringAsFixed(2)}',
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
                                onPressed: () => _handleBooking(context),
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
                        // Use _localFlight.to for weather title
                        Text("in (${_localFlight!.to})",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                            softWrap: true,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 15),
                        Consumer<WeatherProvider>(
                          builder: (context, weatherProvider, _) {
                            if (weatherProvider.isLoading) {
                              return const Center(child: CircularProgressIndicator());
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
                                    width: 180,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Card(
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
                        FutureBuilder(
                          future: _placesFuture, // This future is set based on _localFlight
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              print("Error fetching places: ${snapshot.error}");
                              return Center(child: Text("Error loading places: ${snapshot.error}"));
                            } else {
                              // Access places directly from provider, as FutureBuilder is mainly waiting for the future completion now
                              final places = Provider.of<PlaceProvider>(context, listen: false).places;
                              if (places.isEmpty) {
                                return const Center(child: Text("No places found"));
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
                                              height: 180,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 180,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                                );
                                              },
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
    // Implementation remains the same
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
        _buildPassengerTypeSelector(
          label: 'Adults',
          count: _numberOfAdults,
          onIncrement: () {
            setState(() {
              _numberOfAdults++;
            });
          },
          onDecrement: () {
            setState(() {
              if (_numberOfAdults > 0) {
                _numberOfAdults--;
              }
            });
          },
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 8),
        _buildPassengerTypeSelector(
          label: 'Children',
          count: _numberOfChildren,
          onIncrement: () {
            setState(() {
              _numberOfChildren++;
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
    // Implementation remains the same
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: primaryColor),
              onPressed: onDecrement,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: primaryColor),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }

  // Updated _infoRow to accept primaryColor
  Widget _infoRow(IconData icon, String label, String value, Color primaryColor) {
    // Implementation remains the same
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