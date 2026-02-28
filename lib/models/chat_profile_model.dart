import 'dart:convert';

enum OnlineStatus { online, typing, offline }

class ChatProfileModel {
  final String id;
  final String name;
  final String? profileImagePath;
  final String? statusText;
  final OnlineStatus onlineStatus;
  final String? lastSeenText;
  final String chatBackgroundColor;
  final bool isPremium;

  ChatProfileModel({
    required this.id,
    required this.name,
    this.profileImagePath,
    this.statusText,
    this.onlineStatus = OnlineStatus.offline,
    this.lastSeenText,
    this.chatBackgroundColor = '#ECE5DD',
    this.isPremium = false,
  });

  ChatProfileModel copyWith({
    String? id,
    String? name,
    String? profileImagePath,
    String? statusText,
    OnlineStatus? onlineStatus,
    String? lastSeenText,
    String? chatBackgroundColor,
    bool? isPremium,
  }) {
    return ChatProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      statusText: statusText ?? this.statusText,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastSeenText: lastSeenText ?? this.lastSeenText,
      chatBackgroundColor: chatBackgroundColor ?? this.chatBackgroundColor,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImagePath': profileImagePath,
      'statusText': statusText,
      'onlineStatus': onlineStatus.index,
      'lastSeenText': lastSeenText,
      'chatBackgroundColor': chatBackgroundColor,
      'isPremium': isPremium,
    };
  }

  factory ChatProfileModel.fromJson(Map<String, dynamic> json) {
    return ChatProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImagePath: json['profileImagePath'] as String?,
      statusText: json['statusText'] as String?,
      onlineStatus: OnlineStatus.values[json['onlineStatus'] as int? ?? 2],
      lastSeenText: json['lastSeenText'] as String?,
      chatBackgroundColor: json['chatBackgroundColor'] as String? ?? '#ECE5DD',
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ChatProfileModel.fromJsonString(String jsonString) {
    return ChatProfileModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'ChatProfileModel(id: $id, name: $name, onlineStatus: $onlineStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
