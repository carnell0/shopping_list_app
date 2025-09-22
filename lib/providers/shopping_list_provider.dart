// gestion de l'&tat et logique métier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grocery_item.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart';

class ShoppingListNotifier extends AsyncNotifier<List<GroceryItem>> {
  late final StorageService _storageService;
  late final WebSocketService _webSocketService;
  late final String _clientId;

  @override
  Future<List<GroceryItem>> build() async {
    _clientId = uuid.v4();
    _storageService = ref.read(storageServiceProvider);
    _webSocketService = ref.read(webSocketServiceProvider);

    await _storageService.init(); // Initialise Hive
    
    // Connecte le WebSocket et écoute les messages
    _webSocketService.connect();
    _webSocketService.messages.listen(_handleWebSocketMessage);

    return _storageService.loadItems();
  }

  // Gère les messages entrants du WebSocket
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    if (message['sender'] == _clientId) {
      return;
    }

    final String type = message['type'] as String;
    Map<String, dynamic>? itemData;
    String? itemId;

    if (message.containsKey('item')) {
      itemData = message['item'] as Map<String, dynamic>;
      itemId = itemData['id'] as String;
    }

    List<GroceryItem> currentList = state.value!;

    if (type == 'add' && itemData != null) {
      final newItem = GroceryItem.fromJson(itemData);
      currentList = [...currentList, newItem];
    } else if (type == 'toggle' && itemId != null) {
      currentList = currentList.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isDone: !item.isDone);
        }
        return item;
      }).toList();
    } else if (type == 'delete' && itemId != null) {
      currentList = currentList.where((item) => item.id != itemId).toList();
    }
    
    state = AsyncValue.data(currentList);
    _storageService.saveItems(state.value!);
  }

  // ajout de l'article
  void addItem(String name) {
    final newItem = GroceryItem(name: name);
    state = AsyncValue.data([...state.value!, newItem]);
    _storageService.saveItems(state.value!);
    _webSocketService.sendMessage({'type': 'add', 'item': newItem.toJson(), 'sender': _clientId});
  }

  void toggleItemStatus(String id) { //on détermine le type et le format de message envoyé au serveur 
    state = AsyncValue.data([
      for (final item in state.value!)
        if (item.id == id)
          item.copyWith(isDone: !item.isDone)
        else
          item,
    ]);
    _storageService.saveItems(state.value!);
    final toggledItem = state.value!.firstWhere((item) => item.id == id);
    _webSocketService.sendMessage({'type': 'toggle', 'item': toggledItem.toJson(), 'sender': _clientId});
  }

  void removeItem(String id) {
    state = AsyncValue.data(state.value!.where((item) => item.id != id).toList());
    _storageService.saveItems(state.value!);
    _webSocketService.sendMessage({'type': 'delete', 'item': {'id': id}, 'sender': _clientId});
  }
}

final shoppingListProvider = AsyncNotifierProvider<ShoppingListNotifier, List<GroceryItem>>(
  () => ShoppingListNotifier(),
);
