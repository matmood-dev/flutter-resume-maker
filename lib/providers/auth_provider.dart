import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() : super(const AuthState()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription =
        _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session != null) {
        final profile = await _fetchProfile(session.user.id);
        return state.copyWith(
          user: profile,
          isAuthenticated: true,
          clearError: true,
        );
      } else {
        return state.copyWith(
          user: null,
          isAuthenticated: false,
          clearError: true,
        );
      }
    }).listen((newState) {
      state = newState;
    });
  }

  Future<UserModel?> _fetchProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return UserModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final profile = await _fetchProfile(response.user!.id);
        state = state.copyWith(
          user: profile,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Login failed.');
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  Future<void> register(
      String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user != null) {
        if (response.session != null) {
          final profile = await _fetchProfile(response.user!.id);
          state = state.copyWith(
            user: profile,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Please check your email to confirm your account.',
          );
        }
      } else {
        state = state.copyWith(isLoading: false, error: 'Registration failed.');
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.auth.signOut();
      state = const AuthState();
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      state = state.copyWith(isLoading: false, error: 'No user logged in.');
      return;
    }

    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;

      if (updates.isNotEmpty) {
        await _supabase.from('profiles').update(updates).eq('id', userId);
      }

      final profile = await _fetchProfile(userId);
      state = state.copyWith(user: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to update profile.');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
