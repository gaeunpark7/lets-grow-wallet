import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 대시보드에서 선택한 기준 월(1일 기준).
/// 기본값은 현재 월의 1일
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});
