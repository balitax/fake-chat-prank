import 'dart:convert';

class GroupMemberModel {
  final String id;
  final String name;
  final int colorValue;

  GroupMemberModel({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  GroupMemberModel copyWith({
    String? id,
    String? name,
    int? colorValue,
  }) {
    return GroupMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int,
    );
  }

  static const List<int> availableColors = [
    0xFF25D366, // green
    0xFF2196F3, // blue
    0xFFE91E63, // pink
    0xFFFF9800, // orange
    0xFF9C27B0, // purple
    0xFFFF5722, // deep orange
    0xFF00BCD4, // cyan
    0xFF795548, // brown
  ];
}
