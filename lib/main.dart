import 'package:FlyHigh/screens/flights/PublicFlights.dart';
import 'package:FlyHigh/screens/places/public_places.dart';
import 'package:FlyHigh/providers/City_Provider.dart';
import 'package:FlyHigh/providers/weather_provider.dart';
import 'package:FlyHigh/screens/Start/signUpScreen.dart';
import 'package:FlyHigh/screens/Start/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:FlyHigh/screens/BottomNavigationBar.dart';
import 'package:FlyHigh/screens/Start/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'providers/counter_bloc.dart';
import 'providers/routes.dart';
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
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        BlocProvider(create: (_) => CounterBloc()),
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
          '/PublicPlacesPage': (context) => const PublicPlacesPage(),
          '/PublicFlightsPage': (context) => const PublicFlightsPage(),
        },
      ),
    );
  }
}


