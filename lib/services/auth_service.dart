// Logique d'authentification biométrique
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticate() async {
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  if (!canAuthenticateWithBiometrics) {
    return false;
  }
  
  try {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Veuillez vous authentifier pour accéder à votre liste de courses.',
      options: const AuthenticationOptions(
        biometricOnly: true, // N'autorise que la biométrie (Touch ID/Face ID)
        stickyAuth: true,
      ),
    );
    debugPrint('DEBUG: Authentification réussie: $didAuthenticate');
    return didAuthenticate;
  } catch (e) {
    // Gérer les erreurs (ex: utilisateur annule, appareil non compatible, etc.)
    debugPrint('DEBUG: Erreur capturée lors de l\'authentification biométrique: $e');
    return false;
  }
}
