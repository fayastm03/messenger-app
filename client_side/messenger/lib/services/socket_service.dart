import 'dart:io';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() {
    return _instance;
  }
  SocketService._internal();

  IO.Socket? socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool get isConnected => socket?.connected ?? false;

  final socketUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000'
      : 'http://localhost:3000';

  void connect() {
    if (socket != null && socket!.connected) {
      return;
    }
    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) async {
      print("Connected to socket server");
      final userId = await _storage.read(key: 'userId');
      if (userId != null) {
        socket?.emit("registerUser", userId);
        print("Socket ID: ${socket?.id}");
      }
    });

    socket?.onConnectError((err) {
      print("Socket connect error: $err");
    });

    socket?.onError((err) {
      print("Socket error: $err");
    });

    socket?.onDisconnect((_) {
      print("Disconnected from socket server");
    });
  }
}
