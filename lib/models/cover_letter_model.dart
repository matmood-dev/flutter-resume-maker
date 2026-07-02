import 'package:uuid/uuid.dart';

class CoverLetter {
  final String id;
  final String userId;
  final String resumeId;
  final String companyName;
  final String position;
  final String content;
  final DateTime createdAt;

  CoverLetter({
    String? id,
    required this.userId,
    required this.resumeId,
    required this.companyName,
    required this.position,
    required this.content,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  CoverLetter copyWith({
    String? id,
    String? userId,
    String? resumeId,
    String? companyName,
    String? position,
    String? content,
    DateTime? createdAt,
  }) {
    return CoverLetter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      resumeId: resumeId ?? this.resumeId,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'resumeId': resumeId,
      'companyName': companyName,
      'position': position,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CoverLetter.fromMap(Map<String, dynamic> map) {
    return CoverLetter(
      id: map['id'] as String,
      userId: map['userId'] as String,
      resumeId: map['resumeId'] as String,
      companyName: map['companyName'] as String,
      position: map['position'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
