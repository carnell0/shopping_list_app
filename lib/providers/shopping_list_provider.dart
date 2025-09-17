// lib/providers/shopping_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item.dart';

class ShoppingListNotifier extends AsyncNotifier<List<GroceryItem>> {
  // Constante pour le nom de la boîte Hive
  static const _shoppingListBoxName = 'shoppingListBox';
  
  // Instance de la boîte Hive
  late final Box<GroceryItem> _box;

  // La méthode 'build' est maintenant asynchrone et gère le chargement initial
  @override
  Future<List<GroceryItem>> build() async {
    // 1. Initialise Hive
    await Hive.initFlutter();
    
    // 2. Enregistre l'adapter généré pour notre classe
    if (!Hive.isBoxOpen(_shoppingListBoxName)) {
      if (!Hive.isAdapterRegistered(0)) { // 0 est le typeId de notre classe
        Hive.registerAdapter(GroceryItemAdapter()); // L'adapter est dans le fichier .g.dart
      }
      _box = await Hive.openBox<GroceryItem>(_shoppingListBoxName);
    } else {
      _box = Hive.box<GroceryItem>(_shoppingListBoxName);
    }
    
    // 3. Retourne la liste des items stockés
    return _box.values.toList();
  }

  // Méthode pour sauvegarder l'état actuel de la liste
  Future<void> _save() async {
    // 1. On efface toutes les données existantes dans la boîte
    await _box.clear();
    
    // 2. On ajoute tous les items de l'état actuel
    await _box.addAll(state.value!);
  }

  // --- Méthodes de modification de l'état ---
  void addItem(String name) {
    state = AsyncValue.data([...state.value!, GroceryItem(name: name)]);
    _save(); // Sauvegarde après la mise à jour de l'état
  }

  void toggleItemStatus(String id) {
    state = AsyncValue.data([
      for (final item in state.value!)
        if (item.id == id)
          GroceryItem(name: item.name, isDone: !item.isDone, id: item.id)
        else
          item,
    ]);
    _save();
  }

  void removeItem(String id) {
    state = AsyncValue.data(state.value!.where((item) => item.id != id).toList());
    _save();
  }
}

// Notre provider devient un AsyncNotifierProvider
final shoppingListProvider = AsyncNotifierProvider<ShoppingListNotifier, List<GroceryItem>>(
  () => ShoppingListNotifier(),
);
