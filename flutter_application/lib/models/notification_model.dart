import 'dart:convert';

import 'package:uuid/uuid.dart';

class NotificationModel {
  final String id;
  final DateTime createdAt;
  final bool? seen;
  final String? type;
  final String? postId;
  final List<String>? relativeIds;

  NotificationModel({
    String? id,
    DateTime? createdAt,
    this.seen = false,
    this.type,
    this.postId,
    this.relativeIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      seen: map['seen'] as bool?,
      type: map['type'] as String?,
      postId: map['post_id'] as String?,
      relativeIds: map['relative_ids'] != null
          ? List<String>.from(jsonDecode(map['relative_ids']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'seen': seen,
      'type': type,
      'post_id': postId,
      'relative_ids': relativeIds,
    };
  }
}