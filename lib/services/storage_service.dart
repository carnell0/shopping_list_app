// encapsule la logique d'interaction avec Hive
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageService {
  late final Box<GroceryItem> _box;
  static const _shoppingListBoxName = 'shoppingListBox'; // Nom de la boîte Hive

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_shoppingListBoxName)) {
      if (!Hive.isAdapterRegistered(0)) { // 0 est le typeId de GroceryItem
        Hive.registerAdapter(GroceryItemAdapter()); // L'adapter généré par Hive_generator
      }
      _box = await Hive.openBox<GroceryItem>(_shoppingListBoxName);
    } else {
      _box = Hive.box<GroceryItem>(_shoppingListBoxName);
    }
  }

  List<GroceryItem> loadItems() {
    return _box.values.toList();
  }

  Future<void> saveItems(List<GroceryItem> items) async {
    await _box.clear(); // Efface toutes les anciennes données
    await _box.addAll(items); // Ajoute toutes les nouvelles données
  }

  // Des méthodes plus fines pourraient être ajoutées ici si nécessaire pour la performance:
  // Future<void> addItem(GroceryItem item) async => await _box.put(item.id, item);
  // Future<void> void updateItem(GroceryItem item) async => await _box.put(item.id, item);
  // Future<void> deleteItem(String id) async => await _box.delete(id);
}

// Fournisseur Riverpod pour injecter le service de stockage
final storageServiceProvider = Provider((ref) => StorageService());
