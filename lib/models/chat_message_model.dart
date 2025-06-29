import 'dart:convert';

ChatMessage chatMessageFromJson(String str) => ChatMessage.fromJson(json.decode(str));

class ChatMessage {
    final int id;
    final int senderId;
    final String message;
    final DateTime createdAt;

    ChatMessage({
        required this.id,
        required this.senderId,
        required this.message,
        required this.createdAt,
    });

    factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json["id"],
        senderId: json["sender_id"],
        message: json["message"],
        createdAt: DateTime.parse(json["created_at"]),
    );
}