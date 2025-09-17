// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/shopping_list_page.dart';
import 'services/auth_service.dart';

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
      home: const AuthScreenWrapper(),
    );
  }
}

// Dans votre fichier lib/main.dart ou lib/auth_screen_wrapper.dart

class AuthScreenWrapper extends StatefulWidget {
  const AuthScreenWrapper({super.key});

  @override
  State<AuthScreenWrapper> createState() => _AuthScreenWrapperState();
}

class _AuthScreenWrapperState extends State<AuthScreenWrapper> {
  bool _isAuthenticated = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Lance l'authentification au démarrage de l'écran
    _startAuthentication();
  }

  Future<void> _startAuthentication() async {
    setState(() {
      _isLoading = true; // Affiche l'indicateur de chargement
    });
    final success = await authenticate();
    setState(() {
      _isAuthenticated = success; // Met à jour l'état d'authentification
      _isLoading = false; // Cache l'indicateur
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      // Si l'authentification est réussie, on affiche la page de la liste
      return const ShoppingListPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentification Requise'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              const Icon(Icons.lock, size: 50),
            
            const SizedBox(height: 16),
            
            const Text(
              "Authentification biométrique requise pour continuer.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _startAuthentication, // Bouton pour relancer l'authentification
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}