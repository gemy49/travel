class Favorite {
  final int id;
  final String type; // "flight" أو "hotel"

  Favorite({required this.id, required this.type});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
  };
}
