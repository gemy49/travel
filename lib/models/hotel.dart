import 'dart:convert';
import 'package:flutter/material.dart';

class Hotel {
  final int id;
  final String city;
  final String name;
  final double price;
  final int availableRooms;

  Hotel({
    required this.id,
    required this.city,
    required this.name,
    required this.price,
    required this.availableRooms,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      city: json['city'],
      name: json['name'],
      price: json['price'].toDouble(),
      availableRooms: json['availableRooms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'name': name,
      'price': price,
      'availableRooms': availableRooms,
    };
  }
}
