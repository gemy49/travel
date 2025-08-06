// models/favorite.dart
class Favorite {
  final int id;
  final String type;

  Favorite({
    required this.id,
    required this.type,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      type: json['type'] ?? '',
    );
  }
}
