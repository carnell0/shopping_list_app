// Gestion de la communication en temps réel
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String _url;
  
  // Utilise un StreamController pour diffuser les messages reçus aux auditeurs
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  WebSocketService(this._url);

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      debugPrint('WebSocket connecté à $_url');
      // Envoie un message de test dès la connexion
      sendMessage({'type': 'ping', 'content': 'hello'});

      _channel!.stream.listen(
        (message) {
          debugPrint('Message reçu du serveur: $message');
          try {
            // Tente de parser le message JSON
            _messageController.add(jsonDecode(message));
          } catch (e) {
            debugPrint('Erreur de parsing JSON: $e');
            _messageController.add({'type': 'error', 'content': 'JSON_PARSE_ERROR', 'original': message});
          }
        },
        onDone: () {
          debugPrint('WebSocket déconnecté');
          _messageController.close();
        },
        onError: (error) {
          debugPrint('Erreur WebSocket: $error');
          _messageController.add({'type': 'error', 'content': error.toString()});
        },
      );
    } catch (e) {
      debugPrint('Erreur de connexion WebSocket: $e');
      _messageController.add({'type': 'error', 'content': 'CONNECT_ERROR', 'details': e.toString()});
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null) {
      final message = jsonEncode(data);
      _channel!.sink.add(message);
      debugPrint('Message envoyé au serveur: $message');
    } else {
      debugPrint('WebSocket non connecté, impossible d\'envoyer le message.');
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
  }

  // Permet de fermer le StreamController si le service est jeté
  void dispose() {
    _messageController.close();
    disconnect();
  }
}

// Fournisseur Riverpod pour le service WebSocket
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  const String serverUrl = 'ws://10.89.44.112:8765';
  final service = WebSocketService(serverUrl);
  
  ref.onDispose(() {
    service.disconnect();
    service.dispose();
  });
  return service;
});
