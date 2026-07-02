import 'package:uuid/uuid.dart';

class Education {
  final String id;
  final String school;
  final String degree;
  final String major;
  final double? gpa;
  final DateTime graduationDate;

  Education({
    String? id,
    required this.school,
    required this.degree,
    required this.major,
    this.gpa,
    required this.graduationDate,
  }) : id = id ?? const Uuid().v4();

  Education copyWith({
    String? id,
    String? school,
    String? degree,
    String? major,
    double? gpa,
    DateTime? graduationDate,
  }) {
    return Education(
      id: id ?? this.id,
      school: school ?? this.school,
      degree: degree ?? this.degree,
      major: major ?? this.major,
      gpa: gpa ?? this.gpa,
      graduationDate: graduationDate ?? this.graduationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school': school,
      'degree': degree,
      'major': major,
      'gpa': gpa,
      'graduationDate': graduationDate.toIso8601String(),
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'] as String,
      school: map['school'] as String,
      degree: map['degree'] as String,
      major: map['major'] as String,
      gpa: map['gpa'] as double?,
      graduationDate: DateTime.parse(map['graduationDate'] as String),
    );
  }
}
