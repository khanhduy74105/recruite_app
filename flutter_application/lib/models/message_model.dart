import 'package:uuid/uuid.dart';

class MessageModel {
  String id;
  String? senderId;
  String? receiverId;
  String? content;
  DateTime? sentAt;
  DateTime? readAt;

  MessageModel({
    String? id,
    this.senderId,
    this.receiverId,
    this.content,
    DateTime? sentAt,
    this.readAt,
  })  : id = id ?? const Uuid().v4(),
        sentAt = sentAt ?? DateTime.now();

  // From JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String?,
      receiverId: json['receiver_id'] as String?,
      content: json['content'] as String?,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'sent_at': sentAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  // Setters
  void setSenderId(String? senderId) {
    this.senderId = senderId;
  }

  void setReceiverId(String? receiverId) {
    this.receiverId = receiverId;
  }

  void setContent(String? content) {
    this.content = content;
  }

  void setSentAt(DateTime? sentAt) {
    this.sentAt = sentAt;
  }

  void setReadAt(DateTime? readAt) {
    this.readAt = readAt;
  }
}