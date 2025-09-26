import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  const String serverUrl ='ws://10.87.75.112:8765';
  
  final service = WebSocketService(serverUrl);

  service.connect();

  ref.onDispose(() {
    debugPrint("WebSocketService: Le provider est détruit, déconnexion.");
    service.dispose();
  });

  return service;
});

final webSocketMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.messages;
});

class WebSocketService {
  final String _url;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _reconnectTimer;
  bool _isConnected = false;

  Stream<Map<String, dynamic>> get messages =>
      _messageController?.stream ?? Stream.empty();

  WebSocketService(this._url) {
    _messageController = StreamController<Map<String, dynamic>>.broadcast();
  }

  void connect() {
    if (_isConnected) {
      debugPrint("WebSocketService: Déjà connecté.");
      return;
    }
    
    debugPrint("WebSocketService: Connexion à $_url...");
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _isConnected = true;
      _reconnectTimer?.cancel(); 

      _channel!.stream.listen(
        (message) {
          // Décode le message JSON et l'ajoute au stream.
          try {
            final decodedMessage = jsonDecode(message) as Map<String, dynamic>;
            _messageController?.add(decodedMessage);
            debugPrint("WebSocketService: Message reçu: $decodedMessage");
          } catch (e) {
            debugPrint("WebSocketService: Erreur de décodage JSON: $e");
          }
        },
        onDone: () {
          debugPrint("WebSocketService: Déconnecté du serveur.");
          _isConnected = false;
          _scheduleReconnect();
        },
        onError: (error) {
          debugPrint("WebSocketService: Erreur - $error");
          _isConnected = false;
          _channel = null; 
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint("WebSocketService: Erreur de connexion initiale - $e");
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return; // Déjà planifié.

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      debugPrint("WebSocketService: Tentative de reconnexion...");
      connect();
    });
  }

  void sendMessage(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) {
      debugPrint("WebSocketService: Non connecté. Impossible d'envoyer le message.");
      return;
    }
    
    final message = jsonEncode(data);

    _channel!.sink.add(message);
    debugPrint("WebSocketService: Message envoyé: $message");
  }

  void dispose() {
    debugPrint("WebSocketService: Dispose appelé.");
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController?.close();
    _isConnected = false;
  }
}
