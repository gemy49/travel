class HotelRoom {
  final String type;
  final double price; // أو int
  final int quantity; // أو ربما اسم آخر مثل available?

  // المُنشئ
  HotelRoom({required this.type, required this.price, required this.quantity});
}