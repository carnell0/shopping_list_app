// model des articles
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'grocery_item.g.dart';

const uuid = Uuid();

@HiveType(typeId: 0)
class GroceryItem {
  GroceryItem({
    required this.name,
    this.isDone = false,
    String? id,
  }) : id = id ?? uuid.v4();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isDone;

  //sérialisation/désérialisation JSON
  // Utile pour les communications réseau (WebSocket, API REST)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isDone': isDone,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      isDone: json['isDone'] as bool,
    );
  }

  // Pour la méthode toggleItemStatus, on a besoin d'un copyWith
  // pour mettre à jour l'état
  GroceryItem copyWith({String? id, String? name, bool? isDone}) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
    );
  }
}
