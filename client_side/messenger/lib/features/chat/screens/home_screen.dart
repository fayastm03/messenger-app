import 'package:flutter/material.dart';
import 'package:messenger/features/chat/screens/chat_screen.dart';
import 'package:messenger/models/user_model.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = Provider.of<UserProvider>(context, listen: false);
      provider.initSocketListeners();
      provider.fetchContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddContactDialog,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                provider.updateSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.contacts.isEmpty
                  ? const Center(
                      child: Text(
                        "No contacts yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.filteredContacts.length,
                      itemBuilder: (context, index) {
                        final user = provider.filteredContacts[index];

                        return _buildContactTile(user, provider);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(UserModel user, UserProvider provider) {
    final unread = provider.getUnreadCount(user.id);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),

      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blue.shade100,
        child: Text(
          user.name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      subtitle: Text(
        user.lastMessage?.isNotEmpty == true ? user.lastMessage! : user.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),

      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            user.lastMessageTime != null
                ? _formatMessageTime(user.lastMessageTime!)
                : "",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              _statusDot(provider.onlineUsers.contains(user.id)),

              if (unread > 0) ...[
                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      onTap: () {
        provider.setActiveChatUserId(user.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              name: user.name,
              email: user.email,
              status: user.status,
              userId: user.id,
            ),
          ),
        );
      },
    );
  }

  Widget _statusDot(bool isOnline) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  void _showAddContactDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Contact"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(hintText: "Enter email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  _showMessage("Please enter email");
                  return;
                }

                try {
                  await Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).addContact(email);

                  Navigator.pop(context);

                  _showMessage("Contact added successfully");
                } catch (e) {
                  _showMessage(e.toString().replaceAll("Exception: ", ""));
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  String _formatMessageTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
