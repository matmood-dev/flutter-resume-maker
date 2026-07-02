import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final List<String> technologies;
  final String? githubLink;

  Project({
    String? id,
    required this.name,
    required this.description,
    this.technologies = const [],
    this.githubLink,
  }) : id = id ?? const Uuid().v4();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? technologies,
    String? githubLink,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      githubLink: githubLink ?? this.githubLink,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'githubLink': githubLink,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      technologies: List<String>.from(map['technologies'] ?? []),
      githubLink: map['githubLink'] as String?,
    );
  }
}
