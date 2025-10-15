class GoalModel {
  final String? id;
  final String? userId;
  final String month;
  final String goalType;
  final int? targetAmount;
  final String title;
  final DateTime createdAt;

  GoalModel({
    this.id,
    this.userId,
    required this.month,
    required this.goalType,
    this.targetAmount,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'month': month,
      'goal_type': goalType,
      'target_amount': targetAmount,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static GoalModel fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      month: json['month'] as String,
      goalType: json['goal_type'] as String,
      targetAmount: json['target_amount'] as int?,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
