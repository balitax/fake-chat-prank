import 'dart:convert';

enum OnlineStatus { online, typing, offline }

T _safeEnum<T>(List<T> values, int index, T fallback) {
  return (index >= 0 && index < values.length) ? values[index] : fallback;
}

class ChatProfileModel {
  final String id;
  final String name;
  final String? profileImagePath;
  final String? statusText;
  final OnlineStatus onlineStatus;
  final String? lastSeenText;
  final String chatBackgroundColor;
  final bool isPremium;
  final bool isVerified;

  ChatProfileModel({
    required this.id,
    required this.name,
    this.profileImagePath,
    this.statusText,
    this.onlineStatus = OnlineStatus.offline,
    this.lastSeenText,
    this.chatBackgroundColor = '#ECE5DD',
    this.isPremium = false,
    this.isVerified = false,
  });

  ChatProfileModel copyWith({
    String? id,
    String? name,
    String? profileImagePath,
    bool clearProfileImagePath = false,
    String? statusText,
    bool clearStatusText = false,
    OnlineStatus? onlineStatus,
    String? lastSeenText,
    bool clearLastSeenText = false,
    String? chatBackgroundColor,
    bool? isPremium,
    bool? isVerified,
  }) {
    return ChatProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImagePath: clearProfileImagePath
          ? null
          : (profileImagePath ?? this.profileImagePath),
      statusText: clearStatusText ? null : (statusText ?? this.statusText),
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastSeenText: clearLastSeenText
          ? null
          : (lastSeenText ?? this.lastSeenText),
      chatBackgroundColor: chatBackgroundColor ?? this.chatBackgroundColor,
      isPremium: isPremium ?? this.isPremium,
      isVerified: isVerified ?? this.isVerified,
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
      'isVerified': isVerified,
    };
  }

  factory ChatProfileModel.fromJson(Map<String, dynamic> json) {
    return ChatProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImagePath: json['profileImagePath'] as String?,
      statusText: json['statusText'] as String?,
      onlineStatus: _safeEnum(
        OnlineStatus.values,
        json['onlineStatus'] as int? ?? 2,
        OnlineStatus.offline,
      ),
      lastSeenText: json['lastSeenText'] as String?,
      chatBackgroundColor: json['chatBackgroundColor'] as String? ?? '#ECE5DD',
      isPremium: json['isPremium'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ChatProfileModel.fromJsonString(String jsonString) {
    return ChatProfileModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
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
