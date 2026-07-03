import 'package:uuid/uuid.dart';

class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String previewUrl;
  final bool isPremium;
  final bool isFavorite;

  TemplateModel({
    String? id,
    required this.name,
    this.description = '',
    required this.category,
    this.previewUrl = '',
    this.isPremium = false,
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4();

  TemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? previewUrl,
    bool? isPremium,
    bool? isFavorite,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      previewUrl: previewUrl ?? this.previewUrl,
      isPremium: isPremium ?? this.isPremium,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'preview_url': previewUrl,
      'is_premium': isPremium,
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String,
      previewUrl: map['preview_url'] as String? ?? '',
      isPremium: map['is_premium'] as bool? ?? false,
    );
  }
}
