class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final int amount;
  final String categoryId;
  final String? categoryName;
  final int paymentMethod; // 0: 카드, 1: 현금 등
  final String memo;
  final DateTime date;
  final DateTime createdAt;
  final String type; // income / expense

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.categoryId,
    this.categoryName,
    required this.paymentMethod,
    required this.memo,
    required this.date,
    required this.createdAt,
    required this.type,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] ?? '',
      amount: map['amount'] ?? 0,
      categoryId: map['category_id'] as String,
      categoryName: map['categories']?['name'],
      paymentMethod: map['payment_method'] ?? 0,
      memo: map['memo'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
      type: map['type'] ?? 'expense',
    );
  }

  Map<String, dynamic> toMap() {
    final dateOnly = date.toIso8601String().substring(0, 10);
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'payment_method': paymentMethod,
      'memo': memo,
      'date': dateOnly,
      'type': type,
    };
  }
}
