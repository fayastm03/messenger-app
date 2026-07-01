import 'package:flutter/material.dart';
import 'package:messenger/models/user_model.dart';
import 'package:messenger/services/api_service.dart';
import '../../../services/socket_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socketService = SocketService();

  List<UserModel> contacts = [];
  bool isLoading = false;
  List<String> onlineUsers = [];
  String _searchQuery = "";
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> _unreadCounts = {};
  String? _activeChatUserId;
  bool _socketListenersAttached = false;

  UserProvider({this.lastMessage, this.lastMessageTime});

  void initSocketListeners() {
    if (_socketListenersAttached) return;
    final socket = _socketService.socket;

    if (socket == null && !_socketService.isConnected) return;
    _socketListenersAttached = true;

    _socketService.socket?.off("onlineUsers");
    _socketService.socket?.off("contactUpdated");

    _socketService.socket?.on("onlineUsers", (data) {
      onlineUsers = List<String>.from(data);
      notifyListeners();
      print("Online users: $data");
    });

    _socketService.socket?.on("contactUpdated", (_) async {
      print("Refreshing contacts...");
      await refreshContactsSilenty();
    });
  }

  int getUnreadCount(String userId) {
    return _unreadCounts[userId] ?? 0;
  }

  void incrementUnreadCount(String senderId) {
    if (_activeChatUserId == senderId) {
      return;
    }
    _unreadCounts[senderId] = (_unreadCounts[senderId] ?? 0) + 1;

    notifyListeners();
  }

  void setActiveChatUserId(String? userId) {
    _activeChatUserId = userId;

    if (userId != null) {
      _unreadCounts.remove(userId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> fetchContacts() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getContacts();
      contacts = data.map<UserModel>((u) {
        return UserModel.fromJson(u);
      }).toList();
    } catch (e) {
      print("Error: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addContact(String email) async {
    try {
      isLoading = true;
      notifyListeners();

      await _api.addContact(email);

      await fetchContacts();
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<UserModel> get filteredContacts {
    if (_searchQuery.isEmpty) {
      return contacts;
    } else {
      return contacts.where((contact) {
        return contact.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            contact.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> refreshContactsSilenty() async {
    try {
      final data = await _api.getContacts();
      contacts = data.map<UserModel>((u) {
        return UserModel.fromJson(u);
      }).toList();
      notifyListeners();
    } catch (e) {
      print("Error refreshing contacts: $e");
    }
  }
}
