import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_emotion_service.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';

class CalendarStatNotifier extends AsyncNotifier<Map<DateTime, DailyStat>> {
  final _statService = StatService();
  late DateTime _focusedMonth;

  @override
  Future<Map<DateTime, DailyStat>> build() async {
    // 로그인/로그아웃/계정 전환 시 캘린더 캐시 자동 갱신
    final userId = ref.watch(authUserIdProvider).value;
    if (userId == null) {
      _focusedMonth = DateTime.now();
      return {};
    }

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
      // 로그인/로그아웃/계정 전환 시 이전 계정 감정 아이콘 캐시가 남지 않도록 의존 추가
      final userId = ref.watch(authUserIdProvider).value;
      if (userId == null) return {};
      return UserEmotionService().getEmotionsByMonth(month);
    });
