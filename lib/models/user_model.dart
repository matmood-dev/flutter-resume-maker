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
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'aiCredits': aiCredits,
      'subscriptionTier': subscriptionTier.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      profileImage: map['profileImage'] as String?,
      aiCredits: map['aiCredits'] as int? ?? 10,
      subscriptionTier:
          SubscriptionTier.values[map['subscriptionTier'] as int? ?? 0],
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
