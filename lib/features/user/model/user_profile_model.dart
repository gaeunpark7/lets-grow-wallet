class UserProfileModel {
  final String id;
  final String nickname;
  final String email;
  final bool isPremium;
  final DateTime? premiumPurchasedAt;
  final String? characterImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.isPremium = false,
    this.premiumPurchasedAt,
    this.characterImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      nickname: map['nickname'] ?? '닉네임 없음',
      email: map['email'] ?? '이메일 없음',
      isPremium: (map['is_premium'] as bool?) ?? false,
      premiumPurchasedAt: map['premium_purchased_at'] != null
          ? DateTime.tryParse(map['premium_purchased_at'].toString())
          : null,
      characterImageUrl: map['character_image_url'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'email': email,
      'is_premium': isPremium,
      'premium_purchased_at': premiumPurchasedAt?.toIso8601String(),
      'character_image_url': characterImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? nickname,
    String? email,
    bool? isPremium,
    DateTime? premiumPurchasedAt,
    String? characterImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      isPremium: isPremium ?? this.isPremium,
      premiumPurchasedAt: premiumPurchasedAt ?? this.premiumPurchasedAt,
      characterImageUrl: characterImageUrl ?? this.characterImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
