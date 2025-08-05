class MonthlyStat {
  final DateTime month;
  final int totalIncome;
  final int totalExpense;
  final int cashBalance; // 현금 수입 - 지출
  final int cardBalance; // 카드 수입 - 지출

  MonthlyStat({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.cashBalance,
    required this.cardBalance,
  });

  factory MonthlyStat.fromMap(Map<String, dynamic> map) {
    return MonthlyStat(
      month: DateTime.parse(map['month']),
      totalIncome: map['total_income'],
      totalExpense: map['total_expense'],
      cashBalance: map['cash_balance'],
      cardBalance: map['card_balance'],
    );
  }
}
