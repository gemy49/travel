class availableRoom {
  final String type;
  final int quantity;
  final int price;

  availableRoom({
    required this.type,
    required this.quantity,
    required this.price,
  });

  factory availableRoom.fromJson(Map<String, dynamic> json) {
    return availableRoom(
      type: json['type'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}

class Hotel {
  final int id;
  final String city;
  final String location;
  final String name;
  final List<availableRoom> availableRooms;
  final bool onSale;
  final double rate;
  final String image;
  final String description;
  final List<dynamic> amenities;
  final Map<String, dynamic> contact;



  Hotel({
    required this.id,
    required this.city,
    required this.location,
    required this.name,
    required this.availableRooms,
    required this.onSale,
    required this.rate,
    required this.image,
    required this.description,
    required this.amenities,
    required this.contact,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      city: json['city'],
      location: json['location'],
      name: json['name'],
      availableRooms: (json['availableRooms'] as List<dynamic>)
          .map((room) => availableRoom.fromJson(room))
          .toList(),

      onSale: json['onSale'],
      rate: (json['rate'] ?? 0).toDouble(),
      image: json['image'],
      description: json['description'],
      amenities: json['amenities'] as List<dynamic>,
      contact: json['contact'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'location': location,
      'name': name,
      'availableRooms': availableRooms,
      'onSale': onSale,
      'rate': rate,
      'image': image,
      'description': description,
      'amenities': amenities,
      'contact': contact,
    };
  }
}
