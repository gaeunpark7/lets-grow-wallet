# Riverpod 아키텍처 설명 및 사용 방법

## 📌 개요

Riverpod Notifier 패턴을 사용하여 다음을 구현했습니다:

1. 캘린더에서 감정 등록 시 자동으로 캘린더 새로고침
2. 수입/소비 거래 추가/수정/삭제 시 캘린더 및 통계 화면 자동 업데이트
3. 상태 관리를 통한 중앙화된 데이터 흐름

---

## 🏗️ 아키텍처 구성

### 1. **DailyStatNotifier** (`daily_stat_notifier.dart`)

```dart
final dailyStatNotifierProvider = AsyncNotifierProvider<...>((ref) {
  return DailyStatNotifier();
});

final emotionsByMonthProvider = FutureProvider.family<...>((ref, month) {
  return UserEmotionService().getEmotionsByMonth(month);
});
```

**역할:**

- 월별 일별 통계 데이터 관리 (`Map<DateTime, DailyStat>`)
- 감정 데이터 관리 (`Map<DateTime, String>`)
- 캘린더 새로고침 메서드 제공

**주요 메서드:**

- `refreshDailyStats()`: 캘린더 데이터 새로고침
- `changeMonth(DateTime month)`: 월 변경시 데이터 로드

---

### 2. **TransactionNotifier** (`transaction_notifier.dart`)

```dart
final transactionNotifierProvider = AsyncNotifierProvider<...>((ref) {
  return TransactionNotifier();
});
```

**역할:**

- 월별 거래 내역 관리
- 거래 CRUD 작업 수행

**주요 메서드:**

- `addTransaction()`: 거래 추가 + 캘린더/통계 자동 갱신
- `updateTransaction()`: 거래 수정 + 자동 갱신
- `deleteTransaction()`: 거래 삭제 + 자동 갱신

---

### 3. **StatProvider** (`stat_provider.dart`)

```dart
// 월별 카테고리 통계 (거래 변경시 자동 갱신)
final monthlyCategoryStatsProvider = FutureProvider.family<...>((ref, month) {
  ref.watch(transactionNotifierProvider);  // ← 거래 변경 감지
  return svc.fetchMonthlyCategoryStats(month);
});

// 일별 통계 (거래 변경시 자동 갱신)
final dailyStatProvider = FutureProvider.family<...>((ref, month) {
  ref.watch(transactionNotifierProvider);  // ← 거래 변경 감지
  return svc.fetchDailyStatsForMonth(month);
});
```

---

## 🔄 데이터 흐름

### 시나리오 1: 캘린더에서 감정 등록

```
1. 사용자 감정 선택
   ↓
2. CalendarDetailEmotion._saveEmotion()
   ↓
3. ref.read(dailyStatNotifierProvider.notifier).refreshDailyStats()
   ↓
4. DailyStatNotifier 상태 업데이트
   ↓
5. Calendar 자동 리빌드 (ref.watch 통해)
```

**코드:**

```dart
// calendar_detail_emotion.dart
Future<void> _saveEmotion(String emotion) async {
  await _emotionService.saveEmotion(...);
  // 캘린더 새로고침
  ref.read(dailyStatNotifierProvider.notifier).refreshDailyStats();
}
```

---

### 시나리오 2: 수입/소비 거래 추가/수정/삭제

```
1. 사용자 거래 CRUD
   ↓
2. TransactionNotifier.addTransaction() / updateTransaction() / deleteTransaction()
   ↓
3. 거래 DB 저장 + transactionNotifierProvider 상태 업데이트
   ↓
4. ref.read(dailyStatNotifierProvider.notifier).refreshDailyStats() 호출
   ↓
5. Calendar 자동 리빌드
   ↓
6. monthlyCategoryStatsProvider (ref.watch 통해) 자동 갱신
   ↓
7. StatsExpenseView / StatsIncomeView 자동 리빌드
```

**코드:**

```dart
// transaction_notifier.dart
Future<void> addTransaction(TransactionModel transaction) async {
  await _service.addTransaction(transaction);
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() => _fetchMonthlyTransactions());

  // 캘린더 데이터 새로고침
  ref.read(dailyStatNotifierProvider.notifier).refreshDailyStats();
}
```

---

## 💡 사용 예시

### Calendar에서 사용

```dart
class Calendar extends ConsumerStatefulWidget {
  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  @override
  Widget build(BuildContext context) {
    // 캘린더 데이터 감시
    final statAsyncValue = ref.watch(dailyStatNotifierProvider);
    final emotionAsyncValue = ref.watch(emotionsByMonthProvider(_focusedDay));

    return statAsyncValue.when(
      data: (statMap) {
        return emotionAsyncValue.when(
          data: (emotionMap) {
            // UI 빌드
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 거래 추가/수정/삭제에서 사용

```dart
// add_transaction.dart, edit_transaction.dart 등
class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final transaction = TransactionModel(...);
        // 거래 추가 (자동으로 캘린더/통계 업데이트)
        await ref.read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);

        Navigator.pop(context);
      },
      child: Text('저장'),
    );
  }
}
```

### 통계 화면에서 사용

```dart
class StatsExpenseView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);

    // 거래 변경시 자동으로 갱신됨
    final categoryStatsAsyncValue =
        ref.watch(monthlyCategoryStatsProvider(month));

    return categoryStatsAsyncValue.when(
      data: (stats) {
        // UI 빌드
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

## 🎯 핵심 장점

| 기능        | 이전                         | 현재                      |
| ----------- | ---------------------------- | ------------------------- |
| 데이터 갱신 | 수동 setState 호출           | 자동 (Riverpod 감시)      |
| 코드 복잡도 | StatefulWidget + 여러 Future | ConsumerWidget + Provider |
| 상태 관리   | 산재된 위치                  | 중앙화 (riverpod 폴더)    |
| 캐싱        | 없음                         | 자동 (Provider 기본 기능) |

---

## 📝 체크리스트

거래 추가/수정/삭제 화면을 Riverpod으로 변경하려면:

- [ ] `ConsumerWidget` 또는 `ConsumerStatefulWidget` 사용
- [ ] `transactionNotifierProvider` 주입 (`ref` 사용)
- [ ] 거래 저장 시 `ref.read(transactionNotifierProvider.notifier).addTransaction()`
- [ ] 로딩/에러 상태 처리 (AsyncValue.when 또는 AsyncValue.whenData)

---

## 🔗 참고 파일

- `lib/features/account_book/riverpod/daily_stat_notifier.dart`
- `lib/features/account_book/riverpod/transaction_notifier.dart`
- `lib/features/account_book/riverpod/stat_provider.dart`
- `lib/features/account_book/calendar/screens/calendar.dart`
- `lib/features/account_book/calendar/widgets/calendar_detail_emotion.dart`
