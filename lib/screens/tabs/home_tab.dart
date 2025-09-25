import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shopping_list_provider.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncShoppingList = ref.watch(shoppingListProvider);
    final shoppingListNotifier = ref.read(shoppingListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Liste de Courses'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: asyncShoppingList.when(
        data: (shoppingList) {
          if (shoppingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Votre liste est vide.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ajoutez des articles via l'onglet 'Ajouter'.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              final item = shoppingList[index];
              return ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isDone ? TextDecoration.lineThrough : null,
                    color: item.isDone ? Colors.grey : null,
                  ),
                ),
                leading: Checkbox(
                  value: item.isDone,
                  onChanged: (_) => shoppingListNotifier.toggleItemStatus(item.id),
                  activeColor: Theme.of(context).primaryColor,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => shoppingListNotifier.removeItem(item.id),
                ),
              );
            },
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(child: Text('Erreur : $error'));
        },
      ),
    );
  }
}
