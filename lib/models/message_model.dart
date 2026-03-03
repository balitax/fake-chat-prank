import 'dart:convert';

enum MessageSender { me, other }

enum MessageStatus { sending, sent, delivered, read }

T _safeEnum<T>(List<T> values, int index, T fallback) {
  return (index >= 0 && index < values.length) ? values[index] : fallback;
}

class MessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isDeleted;
  final String? groupMemberId;
  final bool isVoiceNote;
  final int? voiceDuration; // in seconds

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.isDeleted = false,
    this.groupMemberId,
    this.isVoiceNote = false,
    this.voiceDuration,
  });

  MessageModel copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isDeleted,
    String? groupMemberId,
    bool? isVoiceNote,
    int? voiceDuration,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      groupMemberId: groupMemberId ?? this.groupMemberId,
      isVoiceNote: isVoiceNote ?? this.isVoiceNote,
      voiceDuration: voiceDuration ?? this.voiceDuration,
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
      'groupMemberId': groupMemberId,
      'isVoiceNote': isVoiceNote,
      'voiceDuration': voiceDuration,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: _safeEnum(
        MessageSender.values,
        json['sender'] as int,
        MessageSender.me,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: _safeEnum(
        MessageStatus.values,
        json['status'] as int,
        MessageStatus.sent,
      ),
      isDeleted: json['isDeleted'] as bool? ?? false,
      groupMemberId: json['groupMemberId'] as String?,
      isVoiceNote: json['isVoiceNote'] as bool? ?? false,
      voiceDuration: json['voiceDuration'] as int?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory MessageModel.fromJsonString(String jsonString) {
    return MessageModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
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
