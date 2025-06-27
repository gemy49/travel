class Hotel {
  final String name;
  final String city;
  final double price;

  Hotel({required this.name, required this.city, required this.price});

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final property = json['property'];

    return Hotel(
      name: property['name'] ?? 'Unknown Hotel',
      city: property['location']['city']['name'] ?? 'Unknown City',
      price:
          double.tryParse(
            property['priceBreakdown']?['grossPrice']?['value'].toString() ??
                '0',
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'city': city, 'price': price};
  }
}
