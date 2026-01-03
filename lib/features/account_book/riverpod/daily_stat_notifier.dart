import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyStatNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 초기화
  }

  // 일별 통계 새로고침
  Future<void> refreshDailyStats() async {}
}
