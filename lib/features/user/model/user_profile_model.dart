class UserProfileModel {
  final String id;
  final String nickname;
  final String email;
  final String? characterImageUrl;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.characterImageUrl,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      nickname: map['nickname'] ?? '닉네임 없음',
      email: map['email'] ?? '이메일 없음',
      characterImageUrl: map['character_image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'email': email,
      'character_image_url': characterImageUrl,
    };
  }
}
