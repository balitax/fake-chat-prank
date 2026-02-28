import 'dart:convert';

enum MessageSender { me, other }

enum MessageStatus { sending, sent, delivered, read }

class MessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.isDeleted = false,
  });

  MessageModel copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender.index,
      'timestamp': timestamp.toIso8601String(),
      'status': status.index,
      'isDeleted': isDeleted,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: MessageSender.values[json['sender'] as int],
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values[json['status'] as int],
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory MessageModel.fromJsonString(String jsonString) {
    return MessageModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, text: $text, sender: $sender, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
