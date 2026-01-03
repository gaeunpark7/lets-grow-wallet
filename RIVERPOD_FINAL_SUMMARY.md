# 최종 정리: Riverpod 구조 (간단 버전)

## 🎯 핵심 요약

### 3개의 Notifier로 모든 것 관리

```
1. CalendarStatNotifier
   └─ 캘린더에 데이터 넘기기
   └─ 월별 일별 수입/지출 + 감정

2. MonthlyCategoryStatsNotifier  
   └─ 통계 화면에 데이터 넘기기
   └─ 월별 카테고리별 수입/지출 그래프

3. TransactionNotifier
   └─ 거래 추가/수정/삭제
   └─ 자동으로 위 2개 새로고침
```

---

## 🔧 CRUD 시 뭐가 일어나는가?

### 거래 추가

```dart
// 거래 추가 버튼 클릭
await ref.read(transactionNotifierProvider.notifier)
    .addTransaction(transaction);

// ↓ 자동으로 다음이 일어남
// 1. DB에 저장
// 2. CalendarStatNotifier 새로고침 → Calendar 화면 업데이트
// 3. MonthlyCategoryStatsNotifier 새로고침 → Statistics 화면 업데이트
```

**추가 코드 필요 없음!** 자동으로 모든 화면이 업데이트됨 ✨

---

## 📱 UI별 사용법

### Calendar (캘린더)
```dart
class Calendar extends ConsumerStatefulWidget {
  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  @override
  Widget build(BuildContext context) {
    // ✅ 이 한줄로 충분!
    final statsMap = ref.watch(calendarStatNotifierProvider);
    final emotions = ref.watch(emotionsByMonthProvider(_focusedDay));
    
    return statsMap.when(
      data: (data) => TableCalendar(...),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Error'),
    );
  }
}
```

---

### Statistics (통계 - 월별 그래프)
```dart
class StatsGraphView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 이 한줄로 충분!
    final categoryStats = ref.watch(monthlyCategoryStatsNotifierProvider);
    
    return categoryStats.when(
      data: (data) => BarChart(categoryStats: data),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Error'),
    );
  }
}
```

**월 변경 시:**
```dart
ref.read(selectedMonthProvider.notifier).state = newMonth;
// → 자동으로 새로운 월의 그래프 데이터 로드
```

---

### Add/Edit/Delete Transaction (거래 추가/수정/삭제)
```dart
class AddTransactionDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // ✅ 이것만 하면 캘린더 + 통계가 자동으로 업데이트!
        await ref.read(transactionNotifierProvider.notifier)
            .addTransaction(transaction);
        Navigator.pop(context);
      },
      child: Text('저장'),
    );
  }
}
```

**수정/삭제:**
```dart
// 수정
await ref.read(transactionNotifierProvider.notifier)
    .updateTransaction(transaction);

// 삭제
await ref.read(transactionNotifierProvider.notifier)
    .deleteTransaction(transactionId);
```

---

## ⚡ Riverpod의 마법

### 자동 갱신 원리

```dart
// stats_notifier.dart에서
@override
Future<List<MonthlyCategoryStat>> build() async {
  ref.watch(transactionNotifierProvider);  // ← 이 줄이 중요!
  return _statService.fetchMonthlyCategoryStats(...);
}
```

**의미:** 
- "이 Notifier는 transactionNotifierProvider를 감시한다"
- transactionNotifierProvider가 변경되면 자동으로 build() 재실행
- 새로운 데이터로 화면이 업데이트됨

---

## 📝 언제뭘쓰는가? (최종 정리)

### watch() - 데이터 변경 감시 (UI에서 사용)
```dart
// 화면에 표시되는 데이터들
ref.watch(calendarStatNotifierProvider)
ref.watch(monthlyCategoryStatsNotifierProvider)
ref.watch(emotionsByMonthProvider(month))
ref.watch(selectedMonthProvider)
```

### read() - 한 번만 읽기 (버튼 클릭 등 액션에서 사용)
```dart
// 거래 추가/수정/삭제
ref.read(transactionNotifierProvider.notifier).addTransaction(...)

// 월 변경
ref.read(selectedMonthProvider.notifier).state = newMonth
```

---

## ✅ 마지막 체크

### 필요한 수정사항
- [ ] Calendar → ConsumerStatefulWidget + ref.watch() 사용
- [ ] Statistics → ConsumerWidget + ref.watch() 사용  
- [ ] Add/Edit/Delete Transaction → ConsumerWidget + ref.read() 사용
- [ ] 거래 CRUD 시 자동 갱신 확인

### 이미 완료된 것
✅ CalendarStatNotifier 구현
✅ MonthlyCategoryStatsNotifier 구현
✅ TransactionNotifier 구현 (CRUD 중복 코드 제거)
✅ 자동 갱신 체인 구현

---

## 🎉 결과

**데이터 CRUD 한 번 → 자동으로 모든 화면 업데이트**

더 이상 복잡한 상태 관리는 없음! 🚀
