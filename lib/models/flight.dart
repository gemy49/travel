class Flight {
  final int id;
  final String from;
  final String to;
  final String date;
  final String returnDate;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final String airline;
  final Map<String, dynamic>? transit;

  Flight({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.returnDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.airline,
    this.transit,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      date: json['date'],
      returnDate: json['returnDate'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      price: json['price'].toDouble(),
      airline: json['airline'],
      transit: json['transit'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'date': date,
      'returnDate': returnDate,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
      'airline': airline,
      'transit': transit,
    };
  }
}
