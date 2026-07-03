import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/template_model.dart';

class TemplateState {
  final List<TemplateModel> templates;
  final String? selectedCategory;
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
    String? selectedCategory,
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

class TemplateNotifier extends StateNotifier<TemplateState> {
  TemplateNotifier() : super(const TemplateState());

  Future<void> loadTemplates() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await Supabase.instance.client
          .from('templates')
          .select();
      final templates = (data as List)
          .map((row) => TemplateModel.fromMap(row))
          .toList();
      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void filterByCategory(String? category) {
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
