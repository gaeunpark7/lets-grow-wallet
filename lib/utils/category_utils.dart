import 'package:flutter/material.dart';

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
    case '기타':
      return Icons.more_horiz;

    default:
      return Icons.category;
  }
}
