import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart';

const uuid = Uuid();

class ShoppingListNotifier extends AsyncNotifier<List<GroceryItem>> {
  late final StorageService _storageService;
  late final WebSocketService _webSocketService;
  late final String _clientId;

  @override
  Future<List<GroceryItem>> build() async {
    _clientId = uuid.v4();
    _storageService = ref.read(storageServiceProvider);
    _webSocketService = ref.read(webSocketServiceProvider);

    // Écoute les messages entrants du WebSocket
    ref.listen<AsyncValue<Map<String, dynamic>>>(webSocketMessagesProvider, (previous, next) {
      final message = next.value;
      if (message != null) {
        _handleWebSocketMessage(message);
      }
    });

    await _storageService.init();
    return _storageService.loadItems();
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    if (message['sender'] == _clientId) {
      return;
    }

    final type = message['type'] as String?;
    final itemData = message['item'] as Map<String, dynamic>?;

    if (type == null || itemData == null) return;

    final itemId = itemData['id'] as String?;
    var currentList = state.value ?? [];

    switch (type) {
      case 'add':
        final newItem = GroceryItem.fromJson(itemData);
        if (!currentList.any((item) => item.id == newItem.id)) {
          currentList = [...currentList, newItem];
        }
        break;
      case 'toggle':
        if (itemId != null) {
          currentList = [
            for (final item in currentList)
              if (item.id == itemId)
                item.copyWith(isDone: itemData['isDone'] as bool? ?? !item.isDone)
              else
                item,
          ];
        }
        break;
      case 'delete':
        if (itemId != null) {
          currentList = currentList.where((item) => item.id != itemId).toList();
        }
        break;
    }

    state = AsyncValue.data(currentList);
    _storageService.saveItems(currentList);
  }

  void addItem(String name) {
    final newItem = GroceryItem(name: name);
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, newItem]);
    _storageService.saveItems(state.value!);
    _webSocketService.sendMessage({
      'type': 'add',
      'item': newItem.toJson(),
      'sender': _clientId,
    });
  }

  void toggleItemStatus(String id) {
    final currentList = state.value ?? [];
    GroceryItem? toggledItem;
    state = AsyncValue.data([
      for (final item in currentList)
        if (item.id == id)
          (toggledItem = item.copyWith(isDone: !item.isDone))
        else
          item,
    ]);
    _storageService.saveItems(state.value!);
    if (toggledItem != null) {
      _webSocketService.sendMessage({
        'type': 'toggle',
        'item': toggledItem.toJson(),
        'sender': _clientId,
      });
    }
  }

  void removeItem(String id) {
    final currentList = state.value ?? [];
    state = AsyncValue.data(currentList.where((item) => item.id != id).toList());
    _storageService.saveItems(state.value!);
    _webSocketService.sendMessage({
      'type': 'delete',
      'item': {'id': id},
      'sender': _clientId,
    });
  }
}

final shoppingListProvider = AsyncNotifierProvider<ShoppingListNotifier, List<GroceryItem>>(
  () => ShoppingListNotifier(),
);
