import 'package:uuid/uuid.dart';

class Experience {
  final String id;
  final String company;
  final String position;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final List<String> responsibilities;

  Experience({
    String? id,
    required this.company,
    required this.position,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.responsibilities = const [],
  }) : id = id ?? const Uuid().v4();

  Experience copyWith({
    String? id,
    String? company,
    String? position,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    List<String>? responsibilities,
  }) {
    return Experience(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      responsibilities: responsibilities ?? this.responsibilities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrent': isCurrent,
      'responsibilities': responsibilities,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      id: map['id'] as String,
      company: map['company'] as String,
      position: map['position'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      isCurrent: map['isCurrent'] as bool? ?? false,
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
    );
  }
}
