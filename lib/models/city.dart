class Place {
  final int id;
  final String name;
  final String image;
  final String description;

  Place({
    required this.id,
    required this.name,
    required this.image,
    required this.description
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
    );
  }
}

class City {
  final int id;
  final String city;
  final String image;
  final List<Place> places;

  City({
    required this.id,
    required this.city,
    required this.image,
    required this.places,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      city: json['city'],
      image: json['image'],
      places: (json['places'] as List)
          .map((placeJson) => Place.fromJson(placeJson))
          .toList(),
    );
  }
}
