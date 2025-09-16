// lib/providers/shopping_list_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';

// Constante pour la clé de sauvegarde
const _shoppingListKey = 'shoppingList';

// On utilise 'AsyncNotifier' au lieu de 'Notifier'
class ShoppingListNotifier extends AsyncNotifier<List<GroceryItem>> {

  // La méthode 'build' est maintenant asynchrone et gère le chargement initial
  @override
  Future<List<GroceryItem>> build() async {
    // 1. On attend que les SharedPreferences soient prêts
    final prefs = await SharedPreferences.getInstance();
    
    // 2. On récupère la chaîne JSON sauvegardée
    final String? itemsJsonString = prefs.getString(_shoppingListKey);

    if (itemsJsonString != null) {
      // 3. On décode la chaîne JSON en liste de Maps
      final List<dynamic> jsonList = jsonDecode(itemsJsonString);
      
      // 4. On convertit chaque Map en objet GroceryItem et on retourne la liste
      return jsonList.map((json) => GroceryItem.fromJson(json)).toList();
    }
    
    // Si rien n'est sauvegardé, on retourne une liste vide
    return [];
  }

  // Méthode privée pour sauvegarder l'état actuel de la liste
  Future<void> _save() async {
    // 1. On récupère l'instance des SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // 2. On convertit la liste d'objets en liste de Maps
    final List<Map<String, dynamic>> jsonList = state.value!.map((item) => item.toJson()).toList();
    
    // 3. On encode la liste de Maps en chaîne JSON et on la sauvegarde
    await prefs.setString(_shoppingListKey, jsonEncode(jsonList));
  }

  // --- Méthodes de modification de l'état ---
  // On utilise 'state = AsyncValue.data(...) pour mettre à jour l'état
  void addItem(String name) {
    state = AsyncValue.data([...state.value!, GroceryItem(name: name)]);
    _save(); // On n'oublie pas de sauvegarder après chaque modification
  }

  void toggleItemStatus(String id) {
    state = AsyncValue.data([
      for (final item in state.value!)
        if (item.id == id)
          GroceryItem(name: item.name, isDone: !item.isDone)
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