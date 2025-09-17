// lib/auth_service.dart
import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticate() async {
  // 1. Vérifie si l'appareil peut utiliser la biométrie
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  if (!canAuthenticateWithBiometrics) {
    // Si la biométrie n'est pas disponible, l'authentification échoue
    return false;
  }
  
  // 2. Tente d'authentifier l'utilisateur
  try {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Veuillez vous authentifier pour accéder à votre liste de courses.',
      options: const AuthenticationOptions(
        biometricOnly: true, // N'autorise que la biométrie (Touch ID/Face ID)
        stickyAuth: true,
      ),
    );
    return didAuthenticate;
  } catch (e) {
    // Gérer les erreurs (ex: utilisateur annule, appareil non compatible, etc.)
    print('Erreur d\'authentification: $e');
    return false;
  }
}