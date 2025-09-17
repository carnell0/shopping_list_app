// lib/models/grocery_item.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'grocery_item.g.dart'; // Ligne magique pour le code généré

const uuid = Uuid();

@HiveType(typeId: 0) // typeId unique pour chaque classe
class GroceryItem {
  GroceryItem({
    required this.name,
    this.isDone = false,
    String? id,
  }) : id = id ?? uuid.v4();

  @HiveField(0) // Index unique pour chaque propriété
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isDone;
}