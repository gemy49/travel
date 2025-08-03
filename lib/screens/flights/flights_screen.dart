import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FlyHigh/providers/flight_provider.dart';
import 'package:FlyHigh/screens/flights/flight_card.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({Key? key}) : super(key: key);

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _dateController;

  String _fromQuery = '';
  String _toQuery = '';
  DateTime? _startDate;

  // عدد العناصر التي ستظهر في البداية
  int _itemsToShow = 20;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _dateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FlightProvider>(context, listen: false).fetchFlights();
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _fromController.clear();
      _toController.clear();
      _dateController.clear();
      _fromQuery = '';
      _toQuery = '';
      _startDate = null;
    });
  }

  void _clearSpecificFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'from':
          _fromController.clear();
          _fromQuery = '';
          break;
        case 'to':
          _toController.clear();
          _toQuery = '';
          break;
        case 'date':
          _startDate = null;
          _dateController.clear();
          break;
      }
    });
  }

  bool _isDateInRange(String flightDate) {
    if (_startDate == null) return true;
    try {
      List<String> dateParts = flightDate.split('-');
      DateTime flightDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      DateTime flightDateOnly =
      DateTime(flightDateTime.year, flightDateTime.month, flightDateTime.day);
      return flightDateOnly.isAfter(_startDate!.subtract(const Duration(days: 1)));
    } catch (e) {
      return true;
    }
  }

  void _loadMoreItems() {
    setState(() {
      _itemsToShow += 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context);

    final filteredFlights = flightProvider.flights.where((flight) {
      bool matchesFrom =
      flight.from.toLowerCase().contains(_fromQuery.toLowerCase());
      bool matchesTo =
      flight.to.toLowerCase().contains(_toQuery.toLowerCase());
      bool matchesDateRange = _isDateInRange(flight.date);
      return matchesFrom && matchesTo && matchesDateRange;
    }).toList();

    final visibleFlights = filteredFlights.take(_itemsToShow).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
          if (_itemsToShow < filteredFlights.length) {
            _loadMoreItems();
          }
        }
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    if (_fromQuery.isNotEmpty ||
                        _toQuery.isNotEmpty ||
                        _startDate != null)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (_fromQuery.isNotEmpty)
                                    Chip(
                                      label: Text("From: $_fromQuery"),
                                      backgroundColor: Colors.white,
                                      onDeleted: () => _clearSpecificFilter('from'),
                                    ),
                                  if (_toQuery.isNotEmpty)
                                    Chip(
                                      label: Text("To: $_toQuery"),
                                      backgroundColor: Colors.white,
                                      onDeleted: () => _clearSpecificFilter('to'),
                                    ),
                                  if (_startDate != null)
                                    Chip(
                                      label: Text("Date: ${_dateController.text}"),
                                      backgroundColor: Colors.white,
                                      onDeleted: () => _clearSpecificFilter('date'),
                                    ),
                                ],
                              ),
                            ),
                            if (_fromQuery.isNotEmpty ||
                                _toQuery.isNotEmpty ||
                                _startDate != null)
                              TextButton(
                                onPressed: _clearAllFilters,
                                child: Text(
                                  "Clear All",
                                  style: TextStyle(color: Colors.blue.shade500),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _fromController,
                      decoration: InputDecoration(
                        hintText: "Where from?",
                        prefixIcon: const Icon(Icons.flight_takeoff),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _fromQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(
                        hintText: "Where do you want to go?",
                        prefixIcon: const Icon(Icons.flight_land),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _toQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              hintText: " Date",
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue.shade400, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue.shade400, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              visibleFlights.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                    "No flights found.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: visibleFlights.length,
                itemBuilder: (context, index) {
                  final flight = visibleFlights[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/flight-details',
                        arguments: flight,
                      );
                    },
                    child: FlightCard(flight: flight),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
