class MessageModel {
  final String id;
  final String text;
  final String sender;
  final String receiverId;
  final DateTime createdAt;
  final bool seen;

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.receiverId,
    required this.createdAt,
    required this.seen,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      text: json['text'],
      sender: json['sender'],
      receiverId: json['receiverId'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      seen: json['seen'] ?? false,
    );
  }
}
