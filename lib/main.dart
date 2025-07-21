import 'package:flutter/material.dart';
import 'package:FlyHigh/BottomNavigationBar.dart';
import 'package:FlyHigh/pages/loginScreen.dart';
import 'package:FlyHigh/pages/signUpScreen.dart';
import 'package:FlyHigh/pages/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/routes.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
// Providers
import 'providers/flight_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/place_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/Login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUp(),
          '/BottomNavigationBar': (context) => const Bottomnavigationbar(),
        },
      ),
    );
  }
}
