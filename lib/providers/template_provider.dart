import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/template_model.dart';

class TemplateState {
  final List<TemplateModel> templates;
  final TemplateCategory? selectedCategory;
  final bool isLoading;
  final String? error;

  const TemplateState({
    this.templates = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  });

  TemplateState copyWith({
    List<TemplateModel>? templates,
    TemplateCategory? selectedCategory,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return TemplateState(
      templates: templates ?? this.templates,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<TemplateModel> get filteredTemplates {
    if (selectedCategory == null) return templates;
    return templates.where((t) => t.category == selectedCategory).toList();
  }
}

final _mockTemplates = [
  TemplateModel(
    id: 'tmpl-001',
    name: 'Modern Edge',
    category: TemplateCategory.modern,
    previewUrl: 'assets/templates/modern_edge.png',
    isPremium: false,
    isFavorite: true,
  ),
  TemplateModel(
    id: 'tmpl-002',
    name: 'Corporate Pro',
    category: TemplateCategory.professional,
    previewUrl: 'assets/templates/corporate_pro.png',
    isPremium: false,
  ),
  TemplateModel(
    id: 'tmpl-003',
    name: 'Artisan',
    category: TemplateCategory.creative,
    previewUrl: 'assets/templates/artisan.png',
    isPremium: true,
  ),
  TemplateModel(
    id: 'tmpl-004',
    name: 'Whitespace',
    category: TemplateCategory.minimal,
    previewUrl: 'assets/templates/whitespace.png',
    isPremium: false,
    isFavorite: true,
  ),
  TemplateModel(
    id: 'tmpl-005',
    name: 'Executive Suite',
    category: TemplateCategory.executive,
    previewUrl: 'assets/templates/executive_suite.png',
    isPremium: true,
  ),
  TemplateModel(
    id: 'tmpl-006',
    name: 'Clean Pass',
    category: TemplateCategory.atsFriendly,
    previewUrl: 'assets/templates/clean_pass.png',
    isPremium: false,
  ),
];

class TemplateNotifier extends StateNotifier<TemplateState> {
  TemplateNotifier() : super(const TemplateState());

  Future<void> loadTemplates() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(templates: _mockTemplates, isLoading: false);
  }

  void filterByCategory(TemplateCategory? category) {
    if (category == state.selectedCategory) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void toggleFavorite(String templateId) {
    final updated = state.templates.map((t) {
      if (t.id == templateId) {
        return t.copyWith(isFavorite: !t.isFavorite);
      }
      return t;
    }).toList();

    state = state.copyWith(templates: updated);
  }
}

final templateProvider = StateNotifierProvider<TemplateNotifier, TemplateState>(
  (ref) => TemplateNotifier(),
);

final filteredTemplatesProvider = Provider<List<TemplateModel>>((ref) {
  return ref.watch(templateProvider).filteredTemplates;
});
