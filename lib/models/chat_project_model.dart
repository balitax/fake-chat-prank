import 'dart:convert';
import 'message_model.dart';
import 'chat_profile_model.dart';

class ChatProjectModel {
  final String id;
  final String name;
  final ChatProfileModel profile;
  final List<MessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatProjectModel({
    required this.id,
    required this.name,
    required this.profile,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatProjectModel copyWith({
    String? id,
    String? name,
    ChatProfileModel? profile,
    List<MessageModel>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile': profile.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatProjectModel.fromJson(Map<String, dynamic> json) {
    return ChatProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profile: ChatProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ChatProjectModel.fromJsonString(String jsonString) {
    return ChatProjectModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'ChatProjectModel(id: $id, name: $name, messages: ${messages.length})';
  }
}
