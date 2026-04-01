class DailyCategoryStatModel {
  final DateTime date;
  final String type; //income/ expense
  final String categoryName;
  final int totalAmount;

  DailyCategoryStatModel({
    required this.date,
    required this.type,
    required this.categoryName,
    required this.totalAmount,
  });
  factory DailyCategoryStatModel.fromMap(Map<String, dynamic> map) {
    return DailyCategoryStatModel(
      date: DateTime.parse(map['date']),
      type: map['type'],
      categoryName: map['category_name'],
      totalAmount: map['total_amount'] ?? 0,
    );
  }
}
