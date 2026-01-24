class UserProfileModel {
  final String id;
  final String nickname;
  final String email;
  final String? characterImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.characterImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      nickname: map['nickname'] ?? '닉네임 없음',
      email: map['email'] ?? '이메일 없음',
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
      'character_image_url': characterImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? nickname,
    String? email,
    String? characterImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      characterImageUrl: characterImageUrl ?? this.characterImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
