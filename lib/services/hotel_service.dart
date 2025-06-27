import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/hotel.dart';

class HotelService {
  static const String _apiKey =
      '2fdb86c225msh1522be7db83e295p100d05jsn95bb8c03bec5';
  static const String _host = 'booking-com15.p.rapidapi.com';

  static Future<List<Hotel>> fetchHotels({String destId = '-2092174'}) async {
    // ✅ تواريخ الوصول والمغادرة ديناميكيًا
    final now = DateTime.now();
    final arrivalDate = DateFormat(
      'yyyy-MM-dd',
    ).format(now.add(const Duration(days: 1)));
    final departureDate = DateFormat(
      'yyyy-MM-dd',
    ).format(now.add(const Duration(days: 2)));

    final uri = Uri.https(_host, '/api/v1/hotels/searchHotels', {
      'dest_id': destId,
      'search_type': 'CITY',
      'arrival_date': arrivalDate,
      'departure_date': departureDate,
      'adults': '1',
      'children_age': '0,17',
      'room_qty': '1',
      'page_number': '1',
      'units': 'metric',
      'temperature_unit': 'c',
      'languagecode': 'en-us',
      'currency_code': 'USD',
    });

    final response = await http.get(
      uri,
      headers: {'x-rapidapi-key': _apiKey, 'x-rapidapi-host': _host},
    );

    print('Hotel API status: ${response.statusCode}');
    print('Hotel API response: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        final List results = json['data']?['hotels'] ?? [];

        return results.map((item) {
          final property = item['property'];
          return Hotel(
            name: property['name'] ?? 'Unknown',
            city: property['location']?['city']?['name'] ?? 'Price',
            price:
                double.tryParse(
                  property['priceBreakdown']?['grossPrice']?['value']
                          ?.toString() ??
                      '0',
                ) ??
                0,
          );
        }).toList();
      } catch (e) {
        throw Exception('Error parsing hotels: $e');
      }
    } else {
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  }
}
