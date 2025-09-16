# Shopping List App

Cette application de liste de courses est un exemple simple construit avec Flutter. Elle permet aux utilisateurs d'ajouter, de supprimer et de marquer des articles comme terminés. L'état de l'application est géré à l'aide de **Riverpod** et les données sont persistantes localement grâce à **shared_preferences**.

## Structure du Projet

Le projet est structuré comme suit :

```
lib/
├── main.dart
├── models/
│   └── grocery_item.dart
└── providers/
    └── shopping_list_provider.dart
```

- **`main.dart`**: C'est le point d'entrée de l'application. Il configure l'application Flutter et fournit le `ProviderScope` de Riverpod. Il contient également l'interface utilisateur principale de la liste de courses.
- **`models/grocery_item.dart`**: Ce fichier définit le modèle de données `GroceryItem`, qui représente un seul article dans la liste de courses.
- **`providers/shopping_list_provider.dart`**: Ce fichier contient le `ShoppingListNotifier` qui gère l'état de la liste de courses.

## Gestion de l'État avec Riverpod

L'application utilise le package `flutter_riverpod` pour la gestion de l'état.

### `shoppingListProvider`

Le principal fournisseur est `shoppingListProvider`, un `AsyncNotifierProvider`. Il est responsable de :

- **Chargement des données**: Au démarrage de l'application, il charge la liste de courses à partir de `shared_preferences`.
- **Mise à jour de l'état**: Il expose des méthodes pour ajouter, supprimer et mettre à jour des articles dans la liste.
- **Persistance des données**: Après chaque modification, il sauvegarde la liste de courses mise à jour dans `shared_preferences`.

### `AsyncNotifier`

Le `ShoppingListNotifier` étend `AsyncNotifier`. Cela lui permet de gérer les états asynchrones (chargement, données, erreur) de manière transparente.

- La méthode `build` est asynchrone et gère le chargement initial des données.
- L'état est mis à jour en utilisant `state = AsyncValue.data(...)`.

### Interface Utilisateur

L'interface utilisateur est construite à l'aide d'un `ConsumerWidget` de Riverpod.

- `ref.watch(shoppingListProvider)` est utilisé pour écouter les changements dans l'état de la liste de courses.
- `asyncShoppingList.when(...)` est utilisé pour afficher différents widgets en fonction de l'état de `AsyncValue` (données, chargement, erreur).
- `ref.read(shoppingListProvider.notifier)` est utilisé pour appeler les méthodes du `ShoppingListNotifier` pour modifier l'état.

## Persistance des Données

La persistance des données est gérée à l'aide du package `shared_preferences`.

- La classe `ShoppingListNotifier` contient une méthode `_save` qui est appelée après chaque modification de la liste de courses.
- La liste des objets `GroceryItem` est convertie en une liste de `Map<String, dynamic>` à l'aide de la méthode `toJson()` dans le modèle `GroceryItem`.
- La liste de maps est ensuite encodée en une chaîne JSON et stockée dans `shared_preferences` sous la clé `_shoppingListKey`.
- Au démarrage de l'application, la chaîne JSON est récupérée, décodée et utilisée pour reconstruire la liste des objets `GroceryItem`.