import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_emotion_service.dart';

class CalendarStatNotifier extends AsyncNotifier<Map<DateTime, DailyStat>> {
  final _statService = StatService();
  late DateTime _focusedMonth;

  @override
  Future<Map<DateTime, DailyStat>> build() async {
    _focusedMonth = DateTime.now();
    return _fetchDailyStatsForMonth(_focusedMonth);
  }

  // 월 변경
  Future<void> changeMonth(DateTime month) async {
    _focusedMonth = month;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDailyStatsForMonth(month));
  }

  // 특정 달의 일별 통계 불러오기(소비, 수입, 감정 등)
  Future<Map<DateTime, DailyStat>> _fetchDailyStatsForMonth(
    DateTime month,
  ) async {
    return _statService.fetchDailyStatsForMonth(month);
  }

  // 캘린더 데이터 새로고침
  Future<void> refreshDailyStats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchDailyStatsForMonth(_focusedMonth),
    );
  }
}

// 캘린더 notifier
final calendarStatNotifierProvider =
    AsyncNotifierProvider<CalendarStatNotifier, Map<DateTime, DailyStat>>(() {
      return CalendarStatNotifier();
    });

// 감정 데이터 notifier
final emotionsByMonthProvider =
    FutureProvider.family<Map<DateTime, String>, DateTime>((ref, month) async {
      return UserEmotionService().getEmotionsByMonth(month);
    });
