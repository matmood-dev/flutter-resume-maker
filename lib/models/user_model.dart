import 'package:uuid/uuid.dart';

enum SubscriptionTier { free, basic, premium, enterprise }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final int aiCredits;
  final SubscriptionTier subscriptionTier;
  final DateTime createdAt;

  UserModel({
    String? id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    this.aiCredits = 10,
    this.subscriptionTier = SubscriptionTier.free,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImage,
    int? aiCredits,
    SubscriptionTier? subscriptionTier,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      aiCredits: aiCredits ?? this.aiCredits,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'ai_credits': aiCredits,
      'subscription_tier': subscriptionTier.index,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    dynamic subTier = map['subscription_tier'] ?? map['subscriptionTier'];
    SubscriptionTier tier = SubscriptionTier.free;
    if (subTier is int) {
      tier = SubscriptionTier.values[subTier.clamp(0, SubscriptionTier.values.length - 1)];
    } else if (subTier is String) {
      final idx = SubscriptionTier.values.indexWhere(
        (e) => e.name == subTier,
      );
      if (idx != -1) tier = SubscriptionTier.values[idx];
    }

    return UserModel(
      id: map['id'] as String,
      fullName: (map['full_name'] as String?) ?? (map['fullName'] as String?) ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: (map['phone_number'] as String?) ?? (map['phoneNumber'] as String?) ?? '',
      profileImage: (map['profile_image'] as String?) ?? (map['profileImage'] as String?),
      aiCredits: map['ai_credits'] as int? ?? map['aiCredits'] as int? ?? 10,
      subscriptionTier: tier,
      createdAt: DateTime.tryParse(
              map['created_at'] as String? ?? map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
