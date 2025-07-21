class Place {
  final String name;
  final String image;

  Place({required this.name, required this.image});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(name: json['name'], image: json['image']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image};
  }
}
