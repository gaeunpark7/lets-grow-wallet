class DailyQuest {
  final String id;
  final String questType;
  final bool isCompleted;
  final bool rewardGiven;
  final DateTime? userDate;
  final DateTime? createdAt;

  DailyQuest({
    required this.id,
    required this.questType,
    required this.isCompleted,
    required this.rewardGiven,
    this.userDate,
    this.createdAt,
  });

  factory DailyQuest.fromMap(Map<String, dynamic> map) {
    return DailyQuest(
      id: map['id']?.toString() ?? '',
      questType: map['quest_type']?.toString() ?? '',
      isCompleted: map['is_completed'] == true,
      rewardGiven: map['reward_given'] == true,
      userDate: map['user_date'] != null
          ? DateTime.tryParse(map['user_date'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }
}
