// class City {
//   final String id;
//   final String name;

//   City({required this.id, required this.name});

//   factory City.fromJson(Map<String, dynamic> json) {
//     return City(id: json['dest_id'] ?? '', name: json['name'] ?? '');
//   }

//   @override
//   String toString() => name;
// }

class City {
  final String name;
  final String id;

  City({required this.name, required this.id});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(name: json['name'] ?? 'Unknown', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}
