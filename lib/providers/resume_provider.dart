import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  static final _sampleResumes = [
    ResumeModel(
      id: 'resume-001',
      userId: 'user-001',
      title: 'Senior Software Engineer',
      personalInfo: PersonalInfo(
        fullName: 'Alex Johnson',
        email: 'alex.johnson@email.com',
        phoneNumber: '+1 (555) 123-4567',
        address: 'San Francisco, CA',
        linkedIn: 'linkedin.com/in/alexjohnson',
        portfolioUrl: 'alexjohnson.dev',
      ),
      summary:
          'Experienced software engineer with 8+ years building scalable web and mobile applications.',
      education: [],
      experience: [],
      skills: ['Dart', 'Flutter', 'Firebase', 'TypeScript', 'AWS', 'Docker'],
      projects: [],
      certificates: [],
      languages: ['English', 'Spanish'],
      templateId: 'tmpl-001',
      atsScore: 87.5,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ResumeModel(
      id: 'resume-002',
      userId: 'user-001',
      title: 'Product Manager',
      personalInfo: PersonalInfo(
        fullName: 'Alex Johnson',
        email: 'alex.johnson@email.com',
        phoneNumber: '+1 (555) 123-4567',
      ),
      summary: 'Product manager with a track record of launching successful SaaS products.',
      education: [],
      experience: [],
      skills: ['Product Strategy', 'Agile', 'Jira', 'SQL', 'User Research'],
      projects: [],
      certificates: [],
      languages: ['English'],
      templateId: 'tmpl-002',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ResumeModel(
      id: 'resume-003',
      userId: 'user-001',
      title: 'UX Designer',
      personalInfo: PersonalInfo(
        fullName: 'Alex Johnson',
        email: 'alex.johnson@email.com',
        phoneNumber: '+1 (555) 123-4567',
      ),
      summary: 'Creative UX designer passionate about human-centered design.',
      education: [],
      experience: [],
      skills: ['Figma', 'Sketch', 'Prototyping', 'User Testing', 'Design Systems'],
      projects: [],
      certificates: [],
      languages: ['English', 'French'],
      atsScore: 72.0,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<void> loadResumes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(resumes: _sampleResumes, isLoading: false);
  }

  Future<void> addResume(ResumeModel resume) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      resumes: [...state.resumes, resume],
      currentResume: resume,
      isLoading: false,
    );
  }

  Future<void> updateResume(ResumeModel updated) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    final list = state.resumes.map((r) => r.id == updated.id ? updated : r).toList();

    state = state.copyWith(
      resumes: list,
      currentResume:
          state.currentResume?.id == updated.id ? updated : state.currentResume,
      isLoading: false,
    );
  }

  Future<void> deleteResume(String id) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      resumes: state.resumes.where((r) => r.id != id).toList(),
      clearCurrent: state.currentResume?.id == id,
      isLoading: false,
    );
  }

  void setCurrentResume(String id) {
    final match = state.resumes.where((r) => r.id == id);
    state = state.copyWith(
      currentResume: match.isNotEmpty ? match.first : null,
    );
  }
}

final resumeProvider = StateNotifierProvider<ResumeNotifier, ResumeState>((ref) {
  return ResumeNotifier();
});

final currentResumeProvider = Provider<ResumeModel?>((ref) {
  return ref.watch(resumeProvider).currentResume;
});
