import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Profile operations

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<void> updateProfile(String userId, {String? fullName, String? phoneNumber}) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>> createProfile(String userId, String fullName, String phoneNumber) async {
    try {
      final response = await _client
          .from('profiles')
          .insert({
            'id': userId,
            'full_name': fullName,
            'phone_number': phoneNumber,
          })
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  // Resume operations

  Future<List<Map<String, dynamic>>> getResumes(String userId) async {
    try {
      final response = await _client
          .from('resumes')
          .select()
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get resumes: $e');
    }
  }

  Future<Map<String, dynamic>?> getResume(String resumeId) async {
    try {
      final response = await _client
          .from('resumes')
          .select()
          .eq('id', resumeId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to get resume: $e');
    }
  }

  Future<Map<String, dynamic>> createResume(Map<String, dynamic> resumeData) async {
    try {
      final response = await _client
          .from('resumes')
          .insert(resumeData)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to create resume: $e');
    }
  }

  Future<void> updateResume(String resumeId, Map<String, dynamic> data) async {
    try {
      await _client
          .from('resumes')
          .update(data)
          .eq('id', resumeId);
    } catch (e) {
      throw Exception('Failed to update resume: $e');
    }
  }

  Future<void> deleteResume(String resumeId) async {
    try {
      await _client
          .from('resumes')
          .delete()
          .eq('id', resumeId);
    } catch (e) {
      throw Exception('Failed to delete resume: $e');
    }
  }

  // Cover letter operations

  Future<List<Map<String, dynamic>>> getCoverLetters(String userId) async {
    try {
      final response = await _client
          .from('cover_letters')
          .select()
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get cover letters: $e');
    }
  }

  Future<Map<String, dynamic>> createCoverLetter(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('cover_letters')
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to create cover letter: $e');
    }
  }

  Future<void> deleteCoverLetter(String letterId) async {
    try {
      await _client
          .from('cover_letters')
          .delete()
          .eq('id', letterId);
    } catch (e) {
      throw Exception('Failed to delete cover letter: $e');
    }
  }

  // Template operations

  Future<List<Map<String, dynamic>>> getTemplates() async {
    try {
      final response = await _client
          .from('templates')
          .select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get templates: $e');
    }
  }
}
