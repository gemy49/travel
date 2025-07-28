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
  late TextEditingController _returnDateController;

  String _fromQuery = '';
  String _toQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _dateController = TextEditingController();
    _returnDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flightProvider = Provider.of<FlightProvider>(
        context,
        listen: false,
      );
      flightProvider.fetchFlights();
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _returnDateController.dispose();
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
          _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        } else {
          _endDate = picked;
          _returnDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _fromController.clear();
      _toController.clear();
      _dateController.clear();
      _returnDateController.clear();
      _fromQuery = '';
      _toQuery = '';
      _startDate = null;
      _endDate = null;
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
        case 'return':
          _endDate = null;
          _returnDateController.clear();
          break;
      }
    });
  }


  bool _isDateInRange(String flightDate) {
    if (_startDate == null && _endDate == null) return true;

    try {
      List<String> dateParts = flightDate.split('-');
      DateTime flightDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      // Set time to start of day for comparison
      DateTime flightDateOnly = DateTime(flightDateTime.year, flightDateTime.month, flightDateTime.day);

      bool afterStart = _startDate == null || flightDateOnly.isAfter(_startDate!.subtract(Duration(days: 1)));
      bool beforeEnd = _endDate == null || flightDateOnly.isBefore(_endDate!.add(Duration(days: 1)));

      return afterStart && beforeEnd;
    } catch (e) {
      print("Date parsing error: $e");
      return true;
    }
  }

  bool _isReturnDateInRange(String flightReturnDate) {
    if (_startDate == null && _endDate == null) return true;

    try {
      List<String> dateParts = flightReturnDate.split('-');
      DateTime flightReturnDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      // Set time to start of day for comparison
      DateTime flightReturnDateOnly = DateTime(flightReturnDateTime.year, flightReturnDateTime.month, flightReturnDateTime.day);

      bool afterStart = _startDate == null || flightReturnDateOnly.isAfter(_startDate!.subtract(Duration(days: 1)));
      bool beforeEnd = _endDate == null || flightReturnDateOnly.isBefore(_endDate!.add(Duration(days: 1)));

      return afterStart && beforeEnd;
    } catch (e) {
      print("Return Date parsing error: $e");
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context);
    final filteredFlights = flightProvider.flights.where((flight) {
      bool matchesFrom = flight.from.toLowerCase().contains(_fromQuery.toLowerCase());
      bool matchesTo = flight.to.toLowerCase().contains(_toQuery.toLowerCase());

      // Check if the flight's date is within the selected range
      bool matchesDateRange = _isDateInRange(flight.date);

      // Check if the flight's returnDate is within the selected range
      bool matchesReturnDateRange = _isReturnDateInRange(flight.returnDate ?? '');

      return matchesFrom && matchesTo && matchesDateRange && matchesReturnDateRange;
    }).toList();

    return Container(
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
                  if (_fromQuery.isNotEmpty || _toQuery.isNotEmpty || _startDate != null || _endDate != null)
                    Container(
                      margin: EdgeInsets.only(top: 10),
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
                                    backgroundColor:Colors.white,
                                    onDeleted: () => _clearSpecificFilter('to'),
                                  ),
                                if (_startDate != null)
                                  Chip(
                                    label: Text("Start: ${_dateController.text}"),
                                    backgroundColor:Colors.white,
                                    onDeleted: () => _clearSpecificFilter('date'),
                                  ),
                                if (_endDate != null)
                                  Chip(
                                    label: Text("End: ${_returnDateController.text}"),
                                    backgroundColor:Colors.white,
                                    onDeleted: () => _clearSpecificFilter('return'),
                                  ),
                              ],
                            ),
                          ),
                          if (_fromQuery.isNotEmpty || _toQuery.isNotEmpty || _startDate != null || _endDate != null)
                            TextButton(
                              onPressed: _clearAllFilters,
                              child: Text("Clear All",style: TextStyle(color: Colors.blue.shade500)),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _fromController,
                    decoration: InputDecoration(
                      hintText: "Where are you flying from?",
                      prefixIcon: Icon(Icons.flight_takeoff),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
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
                      prefixIcon: Icon(Icons.flight_land),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
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
                  // Date filters row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            hintText: "Start Date",
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _returnDateController,
                          decoration: InputDecoration(
                            hintText: "End Date",
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            filteredFlights.isEmpty
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
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredFlights.length,
              itemBuilder: (context, index) {
                final flight = filteredFlights[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/flight-details',
                      arguments: flight,
                    );
                  },
                  child: FlightCard(
                    flight: flight,
                  ),
                );
              },
            ),
        ],
      ),
      ),
    );
  }
}