class BookedRoom {
  final String type;       // نوع الغرفة (single, double, suite)
  final double price;      // سعر الغرفة (إجمالي أو سعر الوحدة)
  final int quantity;      // عدد الغرف المحجوزة

  BookedRoom({
    required this.type,
    required this.price,
    required this.quantity,
  });

  /// إنشاء كائن من JSON
  factory BookedRoom.fromJson(Map<String, dynamic> json) {
    return BookedRoom(
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? json['count'] ?? 0,
      // يدعم count أو quantity
    );
  }

  /// تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'price': price,
      'quantity': quantity,
    };
  }
}
class HotelBooking {
  final String bookingId;
  final int hotelId;
  final String hotelName;
  final String city;
  final List<BookedRoom> rooms;
  final double totalCost;
  final String fullName;
  final String phone;
  final DateTime bookingDate;

  HotelBooking({
    required this.bookingId,
    required this.hotelId,
    required this.hotelName,
    required this.city,
    required this.rooms,
    required this.totalCost,
    required this.fullName,
    required this.phone,
    required this.bookingDate,
  });

  factory HotelBooking.fromJson(Map<String, dynamic> json) {
    return HotelBooking(
      bookingId: json['bookingId'] ?? '',
      hotelId: json['hotelId'] ?? 0,
      hotelName: json['hotelName'] ?? '',
      city: json['city'] ?? '',
      rooms: (json['rooms'] as List<dynamic>)
          .map((room) => BookedRoom.fromJson(room))
          .toList(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      bookingDate: DateTime.tryParse(json['bookingDate'] ?? '') ?? DateTime.now(),
    );
  }
}
