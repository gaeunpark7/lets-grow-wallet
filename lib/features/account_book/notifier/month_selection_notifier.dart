import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';

/// 대시보드에서 선택한 기준 월(1일 기준).
/// 기본값은 현재 월의 1일
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = nowKst();
  return DateTime(now.year, now.month, 1);
});
