import 'package:flutter/material.dart';

const List<String> expenseCategoryOrder = [
  '식비',
  '카페',
  '교통',
  '문화생활',
  '통신',
  '주거',
  '미용/패션',
  '생활용품',
  '건강',
  '교육',
  '경조사',
  '기타',
];

const List<String> incomeCategoryOrder = [
  '월급',
  '부수입',
  '상여금',
  '용돈',
  '투자소득',
  '기타',
];

int getCategorySortIndex(String name, {required String type}) {
  final order = type == 'income' ? incomeCategoryOrder : expenseCategoryOrder;
  final idx = order.indexOf(name);
  return idx == -1 ? 9999 : idx;
}

IconData getCategoryIcon(String name) {
  switch (name) {
    case '식비':
      return Icons.restaurant;
    case '교통':
      return Icons.directions_bus;
    case '주거':
      return Icons.home;
    case '미용/패션':
      return Icons.checkroom;
    case '문화생활':
      return Icons.movie;
    case '건강':
      return Icons.health_and_safety;
    case '교육':
      return Icons.school;
    case '통신':
      return Icons.phone_android;
    case '카페':
      return Icons.local_cafe;
    case '생활용품':
      return Icons.shopping_bag;
    case '경조사':
      return Icons.card_giftcard;
    case '기타':
      return Icons.more_horiz;
    case '월급':
      return Icons.attach_money;
    case '부수입':
      return Icons.monetization_on;
    case '상여금':
      return Icons.work;
    case '용돈':
      return Icons.wallet;
    case '투자소득':
      return Icons.trending_up;
    default:
      return Icons.category;
  }
}
