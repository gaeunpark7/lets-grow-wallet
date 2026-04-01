class MonthlyCategoryStat {
  final String userId;
  final DateTime month;
  final String categoryId;
  final String categoryName;
  final int totalIncome;
  final int totalExpense;

  MonthlyCategoryStat({
    required this.userId,
    required this.month,
    required this.categoryId,
    required this.categoryName,
    required this.totalIncome,
    required this.totalExpense,
  });

  factory MonthlyCategoryStat.fromMap(Map<String, dynamic> map) {
    return MonthlyCategoryStat(
      userId: map['user_id'],
      month: DateTime.parse(map['month']),
      categoryId: map['category_id'],
      categoryName: map['category_name'],
      totalIncome: map['total_income'] ?? 0,
      totalExpense: map['total_expense'] ?? 0,
    );
  }
}
