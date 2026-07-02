import 'package:uuid/uuid.dart';

enum TemplateCategory {
  modern,
  professional,
  creative,
  minimal,
  executive,
  atsFriendly,
}

class TemplateModel {
  final String id;
  final String name;
  final TemplateCategory category;
  final String previewUrl;
  final bool isPremium;
  final bool isFavorite;

  TemplateModel({
    String? id,
    required this.name,
    required this.category,
    required this.previewUrl,
    this.isPremium = false,
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4();

  TemplateModel copyWith({
    String? id,
    String? name,
    TemplateCategory? category,
    String? previewUrl,
    bool? isPremium,
    bool? isFavorite,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
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
      'category': category.index,
      'previewUrl': previewUrl,
      'isPremium': isPremium,
      'isFavorite': isFavorite,
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: TemplateCategory.values[map['category'] as int],
      previewUrl: map['previewUrl'] as String,
      isPremium: map['isPremium'] as bool? ?? false,
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}
