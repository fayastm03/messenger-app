class UserModel {
  final String id;
  final String name;
  final String email;
  final String status;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      status: json['status'] ?? 'offline',
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime']).toLocal()
          : null,
    );
  }
}
