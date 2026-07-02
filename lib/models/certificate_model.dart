import 'package:uuid/uuid.dart';

class Certificate {
  final String id;
  final String name;
  final String organization;
  final DateTime date;

  Certificate({
    String? id,
    required this.name,
    required this.organization,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  Certificate copyWith({
    String? id,
    String? name,
    String? organization,
    DateTime? date,
  }) {
    return Certificate(
      id: id ?? this.id,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'date': date.toIso8601String(),
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'] as String,
      name: map['name'] as String,
      organization: map['organization'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
