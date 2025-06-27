// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/city.dart';

// class FlightService {
//   static const String _apiKey =
//       '2fdb86c225msh1522be7db83e295p100d05jsn95bb8c03bec5';
//   static const String _host = 'booking-com15.p.rapidapi.com';

//   static Future<List<City>> fetchCities(String query) async {
//     final uri = Uri.https(_host, '/api/v1/flights/searchDestination', {
//       'query': query,
//     });

//     final response = await http.get(
//       uri,
//       headers: {'x-rapidapi-key': _apiKey, 'x-rapidapi-host': _host},
//     );

//     if (response.statusCode == 200) {
//       try {
//         final decoded = jsonDecode(response.body);
//         final data = decoded['data'];

//         if (data is List) {
//           return data
//               .map((item) => City.fromJson(item))
//               .where((city) => city.id != null && city.name != null)
//               .toList();
//         } else {
//           throw Exception('Invalid format: data is not a list');
//         }
//       } catch (e) {
//         throw Exception('Error parsing city data: $e');
//       }
//     } else {
//       throw Exception('Failed to fetch cities: ${response.statusCode}');
//     }
//   }
// }

// ==============================================================

import '../models/city.dart';

class FlightService {
  // بيانات وهمية مؤقتة (Dummy Data)
  static Future<List<City>> fetchCities(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final dummyCities = [
      City(name: 'Cairo', id: 'CAI.AIRPORT'),
      City(name: 'Dubai', id: 'DXB.AIRPORT'),
      City(name: 'Istanbul', id: 'IST.AIRPORT'),
      City(name: 'Paris', id: 'CDG.AIRPORT'),
      City(name: 'New York', id: 'JFK.AIRPORT'),
      City(name: 'London', id: 'LHR.AIRPORT'),
    ];

    return dummyCities
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
