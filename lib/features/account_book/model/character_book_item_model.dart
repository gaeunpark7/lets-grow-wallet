class CharacterBookItem {
  final String characterId;
  final String name;
  final String description;
  final int price;

  final bool isOwned;
  final bool isActive;
  final DateTime? acquiredAt;
  final int experience;

  final String eggImageUrl;
  final String childImageUrl;
  final String adultImageUrl;

  const CharacterBookItem({
    required this.characterId,
    required this.name,
    required this.description,
    required this.price,
    required this.isOwned,
    required this.isActive,
    required this.acquiredAt,
    required this.experience,
    required this.eggImageUrl,
    required this.childImageUrl,
    required this.adultImageUrl,
  });

  bool get hasChildUnlocked => isOwned && experience >= 300;
  bool get hasAdultUnlocked => isOwned && experience >= 1000;

  String get displayImageUrl {
    if (!isOwned) return eggImageUrl;
    if (experience < 300) return eggImageUrl;
    if (experience < 1000) return childImageUrl;
    return adultImageUrl;
  }
}
