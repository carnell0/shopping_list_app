// lib/models/grocery_item.dart
import 'package:uuid/uuid.dart';
import 'dart:convert'; // Importez la bibliothèque pour la conversion JSON

const uuid = Uuid();

class GroceryItem {
  GroceryItem({
    required this.name,
    this.isDone = false,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String name;
  final bool isDone;

  // Méthode pour convertir l'objet en Map (JSON)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isDone': isDone,
      };

  // Constructeur pour créer un objet depuis une Map (JSON)
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      isDone: json['isDone'],
    );
  }
}