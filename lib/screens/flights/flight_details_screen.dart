import 'package:flutter/material.dart';
import 'package:FlyHigh/models/flight.dart';
import 'package:FlyHigh/models/hotel.dart';
import 'package:provider/provider.dart';
import '../../providers/place_provider.dart';
import '../../providers/weather_provider.dart';

class FlightDetailsScreen extends StatefulWidget {
  final Flight flight;

  const FlightDetailsScreen({
    Key? key,
    required this.flight,
  }) : super(key: key);

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = Provider.of<PlaceProvider>(context, listen: false)
        .fetchPlaces(city: widget.flight.to);
    Provider.of<WeatherProvider>(context, listen: false)
        .fetchWeather(city: widget.flight.to);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.08,
            ),
            child: SingleChildScrollView(
              child: Column(

                children: [
                  _buildDetailCard(
                    context,
                    title: "Flight Details",

                    children: [
                      _infoRow(Icons.flight_takeoff, 'From', widget.flight.from),
                      _infoRow(Icons.flight_land, 'To', widget.flight.to),
                      _infoRow(Icons.date_range, 'Date', widget.flight.date),
                      _infoRow(Icons.monetization_on, 'Price', '\$${widget.flight.price}'),
                      _infoRow(Icons.airlines, 'Airline', widget.flight.airline),
                      if (widget.flight.transit != null) ...[
                        _infoRow(Icons.location_city, 'Transit City', widget.flight.transit!['transitCity']),
                        _infoRow(Icons.timelapse, 'Transit Duration', widget.flight.transit!['transitDuration']),
                      ]
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud, color: Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Container(
                            width: screenWidth * 0.7,
                            decoration: BoxDecoration(
                            ),
                            child:  Text(
                              "The next three days weather",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700,),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Text("in (${widget.flight.to})",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700,),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer<WeatherProvider>(
                    builder: (context, weatherProvider, _) {
                      if (weatherProvider.isLoading) {
                        return const CircularProgressIndicator();
                      }
                      final forecastDays = weatherProvider.weather?.forecast.forecastday;
                      if (forecastDays == null || forecastDays.isEmpty) {
                        return const Text("لا توجد بيانات طقس متاحة", style: TextStyle(color: Colors.white));
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: forecastDays.map((day) {
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: Card(
                                color: Colors.blue.shade100,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        "https:${day.conditionIcon}",
                                        width: 40,
                                        height: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${day.date}",
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${day.conditionText}",
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      Text(
                                        "High: ${day.maxTempC}°C",
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      Text(
                                        "Low: ${day.minTempC}°C",
                                        style: const TextStyle(color: Colors.black),
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
                  SizedBox(height: screenWidth * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        "Famous Places",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  FutureBuilder(
                    future: _placesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        final places = Provider.of<PlaceProvider>(context).places;
                        if (places.isEmpty) {
                          return const Text(
                            "No places found",
                            style: TextStyle(color: Colors.white),
                          );
                        }
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final place = places[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                    child: Image.asset(
                                      "assets/places/${place.image}",
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Text(
                                    place.name,
                                    style:  TextStyle(color: Colors.blue.shade700, fontSize: 18),
                                  ),
                                  const SizedBox(height: 5),
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,

            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
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
