// import 'package:flutter/material.dart';

// void main() {
//   runApp(MaterialApp(home: MyApp()));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Hello World')),
//       body: Center(child: Image.asset("assets/1.jpg")),
//     );
//   }
// }

//=================================================================

// ملف: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/flight_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/place_provider.dart';

// Screens
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlightProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
      ],
      child: const MaterialApp(
        title: 'Travel Booking App',
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
