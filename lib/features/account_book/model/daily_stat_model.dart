class DailyStat {
  final String userId;
  final DateTime day;
  final int totalIncome;
  final int totalExpense;
  final int cashExpense;
  final int cardExpense;
  final String emotionIcon;

  DailyStat({
    required this.userId,
    required this.day,
    required this.totalIncome,
    required this.totalExpense,
    required this.cashExpense,
    required this.cardExpense,
    required this.emotionIcon,
  });

  factory DailyStat.fromMap(Map<String, dynamic> map) {
    return DailyStat(
      userId: map['user_id'],
      day: DateTime.parse(map['day']),
      totalIncome: map['total_income'] ?? 0,
      totalExpense: map['total_expense'] ?? 0,
      cashExpense: map['cash_expense'] ?? 0,
      cardExpense: map['card_expense'] ?? 0,
      emotionIcon: map['emotion_icon'] ?? '',
    );
  }
}
