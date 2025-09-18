// boite de dialogue pour ajouter un article
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_list_provider.dart';

class AddItemDialog extends ConsumerWidget {
  const AddItemDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    return AlertDialog(
      title: const Text('Ajouter un article'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Nom de l'article"),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              ref.read(shoppingListProvider.notifier).addItem(controller.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
