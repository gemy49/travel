class Booking {
  final String flightId;
  final int id;
  final String from;
  final String to;
  final String date;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final String airline;
  final Map<String, dynamic>? transit; // لو فيه ترانزيت
  final int adults;
  final int children;

  Booking({
    required this.flightId,
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.airline,
    this.transit,
    required this.adults,
    required this.children,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      flightId: json["flightId"] ?? "",
      id: json["id"] ?? 0,
      from: json["from"] ?? "",
      to: json["to"] ?? "",
      date: json["date"] ?? "",
      departureTime: json["departureTime"] ?? "",
      arrivalTime: json["arrivalTime"] ?? "",
      price: (json["price"] != null)
          ? double.tryParse(json["price"].toString()) ?? 0.0
          : 0.0,
      airline: json["airline"] ?? "",
      transit: json["transit"], // ممكن يكون null
      adults: json["adults"] ?? 0,
      children: json["children"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "flightId": flightId,
      "id": id,
      "from": from,
      "to": to,
      "date": date,
      "departureTime": departureTime,
      "arrivalTime": arrivalTime,
      "price": price,
      "airline": airline,
      "transit": transit,
      "adults": adults,
      "children": children,
    };
  }
}
