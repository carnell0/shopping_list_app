import 'package:flutter/material.dart';
import 'shopping_list_page.dart';
import '../services/auth_service.dart';
import 'register_face_screen.dart';
import 'face_unlock_screen.dart';

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
    _startAuthentication();
  }

  Future<void> _startAuthentication() async {
    setState(() {
      _isLoading = true;
    });
    final success = await authenticate();
    setState(() {
      _isAuthenticated = success;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
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
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startAuthentication,
                  child: const Text('Réessayer'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FaceUnlockScreen(),
                      ),
                    );
                  },
                  child: const Text('Face Unlock'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterFaceScreen(),
                  ),
                );
              },
              child: const Text("Pas encore enregistré ? Enregistrer mon visage"),
            ),
          ],
        ),
      ),
    );
  }
}
