# Shopping List App

Une application de liste de courses collaborative et en temps réel, développée avec Flutter.

Cette application permet aux utilisateurs de créer et gérer une liste de courses partagée. Les modifications sont synchronisées instantanément entre tous les appareils connectés. L'accès à l'application est sécurisé par authentification biométrique.

## Fonctionnalités

-   **Collaboration en temps réel** : Les ajouts, suppressions et modifications d'articles sont visibles instantanément par tous les utilisateurs.
-   **Persistance locale** : La liste est sauvegardée sur l'appareil avec Hive, la rendant disponible même sans connexion internet.
-   **Sécurité** : L'accès à l'application est protégé par authentification biométrique (empreinte digitale ou reconnaissance faciale).
-   **Gestion d'état moderne** : Utilisation de Riverpod pour une gestion d'état réactive, prévisible et découplée.

## Technologies Utilisées

-   **Framework :** Flutter
-   **Gestion d'état :** Riverpod
-   **Persistance locale :** Hive
-   **Communication temps réel :** WebSocket
-   **Sécurité :** `local_auth` (Authentification biométrique)
-   **Génération de code :** `build_runner`, `hive_generator`
-   **Backend (non inclus dans ce repo) :** Serveur Python avec `websockets`.

