class DailyQuest {
  final String id;
  final String questType;
  final bool isCompleted;
  final bool rewardGiven;
  final DateTime createdAt;

  DailyQuest({
    required this.id,
    required this.questType,
    required this.isCompleted,
    required this.rewardGiven,
    required this.createdAt,
  });

  factory DailyQuest.fromMap(Map<String, dynamic> map) {
    return DailyQuest(
      id: map['id']?.toString() ?? '',
      questType: map['quest_type']?.toString() ?? '',
      isCompleted: map['is_completed'] ?? false,
      rewardGiven: map['reward_given'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
