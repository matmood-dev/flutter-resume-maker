import 'package:uuid/uuid.dart';

import 'certificate_model.dart';
import 'education_model.dart';
import 'experience_model.dart';
import 'project_model.dart';

class PersonalInfo {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? address;
  final String? linkedIn;
  final String? github;
  final String? portfolioUrl;

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.linkedIn,
    this.github,
    this.portfolioUrl,
  });

  PersonalInfo copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? linkedIn,
    String? github,
    String? portfolioUrl,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      linkedIn: linkedIn ?? this.linkedIn,
      github: github ?? this.github,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'linkedIn': linkedIn,
      'github': github,
      'portfolioUrl': portfolioUrl,
    };
  }

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      address: map['address'] as String?,
      linkedIn: map['linkedIn'] as String?,
      github: map['github'] as String?,
      portfolioUrl: map['portfolioUrl'] as String?,
    );
  }
}

class ResumeModel {
  final String id;
  final String userId;
  final String title;
  final PersonalInfo personalInfo;
  final String summary;
  final List<Education> education;
  final List<Experience> experience;
  final List<String> skills;
  final List<Project> projects;
  final List<Certificate> certificates;
  final List<String> languages;
  final String? templateId;
  final double? atsScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResumeModel({
    String? id,
    required this.userId,
    required this.title,
    required this.personalInfo,
    this.summary = '',
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.projects = const [],
    this.certificates = const [],
    this.languages = const [],
    this.templateId,
    this.atsScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ResumeModel copyWith({
    String? id,
    String? userId,
    String? title,
    PersonalInfo? personalInfo,
    String? summary,
    List<Education>? education,
    List<Experience>? experience,
    List<String>? skills,
    List<Project>? projects,
    List<Certificate>? certificates,
    List<String>? languages,
    String? templateId,
    double? atsScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      personalInfo: personalInfo ?? this.personalInfo,
      summary: summary ?? this.summary,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certificates: certificates ?? this.certificates,
      languages: languages ?? this.languages,
      templateId: templateId ?? this.templateId,
      atsScore: atsScore ?? this.atsScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'personal_info': personalInfo.toMap(),
      'summary': summary,
      'education': education.map((e) => e.toMap()).toList(),
      'experience': experience.map((e) => e.toMap()).toList(),
      'skills': skills,
      'projects': projects.map((e) => e.toMap()).toList(),
      'certificates': certificates.map((e) => e.toMap()).toList(),
      'languages': languages,
      'template_id': templateId ?? '',
      'ats_score': atsScore ?? 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ResumeModel.fromMap(Map<String, dynamic> map) {
    return ResumeModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled',
      personalInfo: map['personal_info'] != null
          ? PersonalInfo.fromMap(map['personal_info'] as Map<String, dynamic>)
          : PersonalInfo(fullName: '', email: '', phoneNumber: ''),
      summary: map['summary'] as String? ?? '',
      education: (map['education'] as List<dynamic>?)
              ?.map((e) => Education.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      experience: (map['experience'] as List<dynamic>?)
              ?.map((e) => Experience.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      skills: (map['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      projects: (map['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      certificates: (map['certificates'] as List<dynamic>?)
              ?.map((e) => Certificate.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      languages: (map['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      templateId: map['template_id'] as String?,
      atsScore: (map['ats_score'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
