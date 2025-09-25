import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shopping_list_provider.dart';

class AddItemTab extends ConsumerStatefulWidget {
  const AddItemTab({super.key});

  @override
  ConsumerState<AddItemTab> createState() => _AddItemTabState();
}

class _AddItemTabState extends ConsumerState<AddItemTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitItem() {
    if (_formKey.currentState!.validate()) {
      final itemName = _nameController.text;
      ref.read(shoppingListProvider.notifier).addItem(itemName);
      
      _nameController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'$itemName' a été ajouté à la liste."),
          duration: const Duration(seconds: 2),
        ),
      );
      
      FocusScope.of(context).previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un article'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'article',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom d\'article.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submitItem(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitItem,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ajouter à la liste'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
