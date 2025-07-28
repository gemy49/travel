import 'package:flutter/material.dart';
import 'package:FlyHigh/models/hotel.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({Key? key, required this.hotel})
    : super(key: key);
  String _formatPriceRange(dynamic priceData) {
    if (priceData is List && priceData.isNotEmpty) {
      try {
        List<double> prices = priceData.map((p) => (p as num).toDouble()).toList();
        double minPrice = prices.reduce((a, b) => a < b ? a : b);
        double maxPrice = prices.reduce((a, b) => a > b ? a : b);
        String minPriceFormatted = minPrice.toStringAsFixed(2);
        if (minPriceFormatted.endsWith('.00')) {
          minPriceFormatted = minPrice.toInt().toString();
        }
        if (minPrice == maxPrice) {
          String singlePriceFormatted = maxPrice.toStringAsFixed(2);
          if (singlePriceFormatted.endsWith('.00')) {
            singlePriceFormatted = maxPrice.toInt().toString();
          }
          return '\$$singlePriceFormatted';
        } else {
          String maxPriceFormatted = maxPrice.toStringAsFixed(2);
          if (maxPriceFormatted.endsWith('.00')) {
            maxPriceFormatted = maxPrice.toInt().toString();
          }
          return '\$$minPriceFormatted~\$$maxPriceFormatted';
        }
      } catch (e) {
        print("Error formatting price range: $e");
        return "N/A";
      }
    } else {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<int> price = hotel.availableRooms.map((room) => room.price).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
         color: Colors.white,
        ),
        child: Row(
          children: [
            // Placeholder for an image (optional)
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/Hotels/${hotel.image}'), // تأكد من توفر الصورة
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'City: ${hotel.city}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Price: (${_formatPriceRange(price)})',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
