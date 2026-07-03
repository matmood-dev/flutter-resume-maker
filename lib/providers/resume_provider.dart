import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/resume_model.dart';

class ResumeState {
  final List<ResumeModel> resumes;
  final ResumeModel? currentResume;
  final bool isLoading;
  final String? error;

  const ResumeState({
    this.resumes = const [],
    this.currentResume,
    this.isLoading = false,
    this.error,
  });

  ResumeState copyWith({
    List<ResumeModel>? resumes,
    ResumeModel? currentResume,
    bool? isLoading,
    String? error,
    bool clearCurrent = false,
    bool clearError = false,
  }) {
    return ResumeState(
      resumes: resumes ?? this.resumes,
      currentResume: clearCurrent ? null : (currentResume ?? this.currentResume),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ResumeNotifier extends StateNotifier<ResumeState> {
  ResumeNotifier() : super(const ResumeState());

  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> loadResumes() async {
    if (_userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _client
          .from('resumes')
          .select()
          .eq('user_id', _userId!);

      final resumes = (response as List)
          .map((json) => ResumeModel.fromMap(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(resumes: resumes, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addResume(ResumeModel resume) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    state = state.copyWith(isLoading: true);
    try {
      await _client.from('resumes').insert(resume.toMap());
      await loadResumes();
      state = state.copyWith(currentResume: resume);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> updateResume(ResumeModel resume) async {
    state = state.copyWith(isLoading: true);
    try {
      await _client
          .from('resumes')
          .update(resume.toMap())
          .eq('id', resume.id);
      await loadResumes();
      if (state.currentResume?.id == resume.id) {
        state = state.copyWith(currentResume: resume);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteResume(String resumeId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _client.from('resumes').delete().eq('id', resumeId);
      state = state.copyWith(
        resumes: state.resumes.where((r) => r.id != resumeId).toList(),
        clearCurrent: state.currentResume?.id == resumeId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setCurrentResume(ResumeModel resume) {
    state = state.copyWith(currentResume: resume);
  }
}

final resumeProvider = StateNotifierProvider<ResumeNotifier, ResumeState>((ref) {
  return ResumeNotifier();
});

final currentResumeProvider = Provider<ResumeModel?>((ref) {
  return ref.watch(resumeProvider).currentResume;
});
