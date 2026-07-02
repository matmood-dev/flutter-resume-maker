import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  AuthNotifier() : super(const AuthState());

  static final _mockUser = UserModel(
    id: 'user-001',
    fullName: 'Alex Johnson',
    email: 'alex.johnson@email.com',
    phoneNumber: '+1 (555) 123-4567',
    aiCredits: 15,
    subscriptionTier: SubscriptionTier.basic,
  );

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'Email and password are required.');
      return;
    }

    state = state.copyWith(
      user: _mockUser.copyWith(email: email),
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(seconds: 1));

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'All fields are required.');
      return;
    }

    state = state.copyWith(
      user: UserModel(fullName: fullName, email: email, phoneNumber: ''),
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = const AuthState();
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImage,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 500));

    final updated = state.user?.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
    );

    if (updated != null) {
      state = state.copyWith(user: updated, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: 'No user logged in.');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
