class StatusModel {
  final String id;
  final String contactName;
  final String? profileImagePath;
  final List<StatusItemModel> items;
  final bool isMine;
  final DateTime updatedAt;

  StatusModel({
    required this.id,
    required this.contactName,
    this.profileImagePath,
    required this.items,
    this.isMine = false,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactName': contactName,
      'profileImagePath': profileImagePath,
      'items': items.map((i) => i.toJson()).toList(),
      'isMine': isMine,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] as String,
      contactName: json['contactName'] as String,
      profileImagePath: json['profileImagePath'] as String?,
      items: (json['items'] as List)
          .map((i) => StatusItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      isMine: json['isMine'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

enum StatusType { image, text, video }

class StatusItemModel {
  final String id;
  final StatusType type;
  final String content; // Image path or text content
  final String? caption;
  final DateTime timestamp;
  final String backgroundColor; // For text status

  StatusItemModel({
    required this.id,
    required this.type,
    required this.content,
    this.caption,
    required this.timestamp,
    this.backgroundColor = '#008069',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'content': content,
      'caption': caption,
      'timestamp': timestamp.toIso8601String(),
      'backgroundColor': backgroundColor,
    };
  }

  factory StatusItemModel.fromJson(Map<String, dynamic> json) {
    return StatusItemModel(
      id: json['id'] as String,
      type: StatusType.values[json['type'] as int? ?? 0],
      content: json['content'] as String,
      caption: json['caption'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      backgroundColor: json['backgroundColor'] as String? ?? '#008069',
    );
  }
}
