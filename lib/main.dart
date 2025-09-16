// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/shopping_list_provider.dart';

void main() {
  // 1. Indispensable ! Encapsule l'app dans un ProviderScope pour que Riverpod fonctionne
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Liste de Courses',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ShoppingListPage(),
    );
  }
}

// 2. Utilisation d'un ConsumerWidget pour accéder au provider
class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. On watch le provider qui retourne maintenant un AsyncValue
    final asyncShoppingList = ref.watch(shoppingListProvider);
    
    // Pour interagir avec le provider on utilise toujours 'ref.read'
    final shoppingListNotifier = ref.read(shoppingListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Liste de Courses'),
      ),
      // 2. On utilise 'when' pour gérer les différents états de l'AsyncValue
      body: asyncShoppingList.when(
        data: (shoppingList) {
          // L'état est en 'data', on peut afficher la liste
          return ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              final item = shoppingList[index];
              return ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                leading: Checkbox(
                  value: item.isDone,
                  onChanged: (_) => shoppingListNotifier.toggleItemStatus(item.id),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => shoppingListNotifier.removeItem(item.id),
                ),
              );
            },
          );
        },
        loading: () {
          // L'état est en 'loading', on affiche un indicateur
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          // L'état est en 'error', on affiche un message
          return Center(child: Text('Erreur : $error'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController controller = TextEditingController();
              return AlertDialog(
                title: const Text('Ajouter un article'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Nom de l'article"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        shoppingListNotifier.addItem(controller.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Ajouter'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}