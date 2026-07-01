import 'package:flutter/material.dart';
import 'package:messenger/features/chat/providers/chat_provider.dart';
import 'package:messenger/models/message_model.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String email;
  final String status;
  final String userId;

  const ChatScreen({
    super.key,
    required this.name,
    required this.email,
    required this.status,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messagecontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late UserProvider _userProvider;
  String? myUserId;
  bool _showScrollBottom = false;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _scrollController.addListener(() {
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - 300) {
        if (!_showScrollBottom) {
          setState(() {
            _showScrollBottom = true;
          });
        }
      } else {
        if (_showScrollBottom) {
          setState(() {
            _showScrollBottom = false;
          });
        }
      }
    });

    Future.microtask(() async {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      myUserId = await provider.getMyUserId();
      await provider.fetchMessages(widget.userId);
      await provider.markMessagesAsSeen(widget.userId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToBottom();
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    _userProvider.setActiveChatUserId(null);
    _scrollController.dispose();
    _messagecontroller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messagecontroller.text.trim();
    if (text.isEmpty) return;

    await Provider.of<ChatProvider>(
      context,
      listen: false,
    ).sendMessage(widget.userId, text);
    _messagecontroller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isOnline = userProvider.onlineUsers.contains(widget.userId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(widget.name[0].toUpperCase()),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name),
                Text(
                  isOnline ? "Online" : "Offline",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: provider.messages.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      final msg = provider.messages[index];
                      final isMe = msg.sender == myUserId;
                      bool showDate = false;
                      if (index == 0) {
                        showDate = true;
                      } else {
                        final previous = provider.messages[index - 1];
                        showDate =
                            previous.createdAt.day != msg.createdAt.day ||
                            previous.createdAt.month != msg.createdAt.month ||
                            previous.createdAt.year != msg.createdAt.year;
                      }
                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getDateLabel(msg.createdAt),
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          _buildMessageBubble(msg, isMe),
                        ],
                      );
                    },
                  ),
          ),

          _buildInputBar(),
        ],
      ),

      floatingActionButton: _showScrollBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: FloatingActionButton(
                mini: true,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward),
              ),
            )
          : null,
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(msg.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messagecontroller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay == today) {
      return "TODAY";
    }

    if (messageDay == yesterday) {
      return "YESTERDAY";
    }

    return "${date.day}/${date.month}/${date.year}";
  }
}
