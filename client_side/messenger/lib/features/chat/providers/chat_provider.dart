import 'package:flutter/material.dart';
import 'package:messenger/models/message_model.dart';
import 'package:messenger/services/api_service.dart';
import 'package:messenger/services/socket_service.dart';
import '../../auth/providers/user_provider.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  UserProvider? userProvider;

  ChatProvider() {
    listenForMessages();
  }

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;
  bool isLoading = false;

  Future<String?> getMyUserId() async {
    return await _apiService.getMyUserId();
  }

  Future<void> fetchMessages(String userId) async {
    isLoading = true;
    notifyListeners();

    final data = await _apiService.getMessages(userId);

    _messages = data.map<MessageModel>((m) {
      return MessageModel.fromJson(m);
    }).toList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String receiverId, String text) async {
    _messages.add(
      MessageModel(
        id: "",
        text: text,
        sender: await getMyUserId() ?? "",
        receiverId: receiverId,
        createdAt: DateTime.now(),
        seen: false,
      ),
    );

    notifyListeners();

    await _apiService.sendMessage(receiverId, text);
  }

  Future<void> markMessagesAsSeen(String userId) async {
    await _apiService.markMessagesAsSeen(userId);
  }

  void listenForMessages() {
    _socketService.socket?.off("receiveMessage");
    _socketService.socket?.on("receiveMessage", (data) {
      print("New message received");
      print("🔥 RECEIVE EVENT HIT");
      print(data);

      _messages.add(
        MessageModel(
          id: "",
          text: data["text"],
          sender: data["sender"] ?? "",
          receiverId: data["receiverId"] ?? "",
          createdAt: DateTime.parse(data["createdAt"]),
          seen: data["seen"] ?? false,
        ),
      );
      userProvider?.incrementUnreadCount(data["sender"] ?? "");
      notifyListeners();
    });
  }
}
