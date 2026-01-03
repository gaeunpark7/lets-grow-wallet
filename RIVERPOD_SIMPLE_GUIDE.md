# Riverpod 구조 설명 (단순화 버전)

## 📊 3개의 Notifier 정리

### 1️⃣ **CalendarStatNotifier** (캘린더용)

**파일:** `calendar_notifier.dart`

**역할:** 월별 일별 통계 데이터 + 감정 데이터

- 월 단위로 모든 날짜의 데이터를 불러옴
- 예: 1월 1일 ~ 1월 31일의 수입/지출 데이터

**주요 기능:**

```dart
calendarStatNotifierProvider  // 월별 일별 통계 Map<DateTime, DailyStat>
emotionsByMonthProvider       // 월별 감정 Map<DateTime, String>
```

**언제 새로고침:**

- 감정 등록 시
- 거래 추가/수정/삭제 시

---

### 2️⃣ **MonthlyCategoryStatsNotifier** (통계 화면용)

**파일:** `stats_notifier.dart`

**역할:** 월별 카테고리별 그래프 데이터

- 선택된 월의 카테고리별 수입/지출 합계

**주요 기능:**

```dart
monthlyCategoryStatsNotifierProvider  // List<MonthlyCategoryStat>
selectedMonthProvider                 // 선택된 월
```

**언제 새로고침:**

- 거래 추가/수정/삭제 시
- 월 변경 시

---

### 3️⃣ **TransactionNotifier** (거래용)

**파일:** `transaction_notifier.dart`

**역할:** 거래 데이터 관리 + CRUD 처리

**주요 기능:**

```dart
transactionNotifierProvider  // List<TransactionModel>

// 거래 추가/수정/삭제 (자동으로 캘린더 + 통계 새로고침)
addTransaction(transaction)
updateTransaction(transaction)
deleteTransaction(transactionId)
```

**자동 갱신 체인:**

```
거래 추가 → transactionNotifierProvider 업데이트
        → calendarStatNotifierProvider 새로고침
        → monthlyCategoryStatsNotifierProvider 새로고침
```

---

## 🎯 핵심: 자동 갱신 원리

### Riverpod의 `ref.watch()` 사용

```dart
@override
Future<List<MonthlyCategoryStat>> build() async {
  _selectedMonth = ref.watch(selectedMonthProvider);      // ① 월 선택 감시
  ref.watch(transactionNotifierProvider);                 // ② 거래 변경 감시
  return _fetchMonthlyCategoryStats(_selectedMonth);
}
```

**의미:**

- ①: selectedMonthProvider가 변경되면 자동 새로고침
- ②: transactionNotifierProvider가 변경되면 자동 새로고침

---

## 🔄 거래 CRUD 후 자동 갱신 흐름

```
사용자 거래 추가
    ↓
TransactionNotifier.addTransaction()
    ↓
DB 저장 + transactionNotifierProvider 상태 변경
    ↓
[자동 감시] CalendarStatNotifier 감지 → refresh()
[자동 감시] MonthlyCategoryStatsNotifier 감지 → refresh()
    ↓
Calendar 화면 자동 리빌드
Statistics 화면 자동 리빌드
```

---

## 💡 UI 적용 방법

### 1️⃣ **Calendar 화면**

```dart
class Calendar extends ConsumerStatefulWidget {
  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // 캘린더 데이터 감시
    final statAsyncValue = ref.watch(calendarStatNotifierProvider);
    final emotionAsyncValue = ref.watch(emotionsByMonthProvider(_focusedDay));

    return statAsyncValue.when(
      data: (statMap) {
        return emotionAsyncValue.when(
          data: (emotionMap) {
            // UI 빌드 - statMap과 emotionMap 사용
            return TableCalendar(...);
          },
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('Error'),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error'),
    );
  }
}
```

---

### 2️⃣ **Statistics 화면**

```dart
class StatsExpenseView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 선택된 월 변경
    return ElevatedButton(
      onPressed: () {
        ref.read(selectedMonthProvider.notifier).state = newMonth;
      },
      child: Text('월 변경'),
    );
  }
}

class StatsGraphView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 통계 데이터 감시 (자동 새로고침됨)
    final categoryStatsAsyncValue =
        ref.watch(monthlyCategoryStatsNotifierProvider);

    return categoryStatsAsyncValue.when(
      data: (categoryStats) {
        // 그래프 빌드
        return BarChart(
          categoryStats: categoryStats,
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error'),
    );
  }
}
```

---

### 3️⃣ **거래 추가/수정/삭제 화면**

```dart
class AddTransactionDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final transaction = TransactionModel(...);

        // 거래 추가 (자동으로 캘린더 + 통계 갱신)
        await ref.read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);

        Navigator.pop(context);  // 자동 갱신 후 닫기
      },
      child: Text('저장'),
    );
  }
}
```

---

## 📝 정리: 언제 뭘 쓰는가?

| 용도          | Provider                               | 용법                                                                 |
| ------------- | -------------------------------------- | -------------------------------------------------------------------- |
| 캘린더 데이터 | `calendarStatNotifierProvider`         | `ref.watch(calendarStatNotifierProvider)`                            |
| 감정 데이터   | `emotionsByMonthProvider(month)`       | `ref.watch(emotionsByMonthProvider(_focusedDay))`                    |
| 통계 데이터   | `monthlyCategoryStatsNotifierProvider` | `ref.watch(monthlyCategoryStatsNotifierProvider)`                    |
| 선택된 월     | `selectedMonthProvider`                | `ref.read/watch(selectedMonthProvider)`                              |
| 거래 CRUD     | `transactionNotifierProvider`          | `ref.read(transactionNotifierProvider.notifier).addTransaction(...)` |

---

## ✅ 체크리스트

- [ ] Calendar를 ConsumerStatefulWidget으로 변경
- [ ] Calendar에서 `ref.watch(calendarStatNotifierProvider)` 사용
- [ ] Statistics에서 `ref.watch(monthlyCategoryStatsNotifierProvider)` 사용
- [ ] 거래 추가 시 `ref.read(transactionNotifierProvider.notifier).addTransaction()` 호출
- [ ] 월 선택 시 `ref.read(selectedMonthProvider.notifier).state = newMonth` 호출

**중요:** 거래 CRUD 시 자동으로 캘린더 + 통계가 새로고침되므로 별도 처리 불필요! 🎉
