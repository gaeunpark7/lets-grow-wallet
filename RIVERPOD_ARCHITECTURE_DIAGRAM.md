# Riverpod 구조 다이어그램

## 📦 3개 Notifier의 관계도

```
┌─────────────────────────────────────────────────────────────────┐
│                      UI Layer (화면)                            │
├──────────────────────────────────────────────────────────────────┤
│  Calendar Screen         Statistics Screen       Add Transaction │
│  (캘린더)               (월별 통계)              (거래 추가)      │
└──────┬───────────────────┬────────────────────────┬──────────────┘
       │ watch()           │ watch()                │ read()
       ↓                   ↓                        ↓
┌─────────────────────────────────────────────────────────────────┐
│                   Notifier Layer (상태 관리)                    │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1️⃣ CalendarStatNotifier                                        │
│     데이터: Map<DateTime, DailyStat> + 감정                      │
│     역할: 월별 일별 데이터 (캘린더용)                            │
│                                                                   │
│  2️⃣ MonthlyCategoryStatsNotifier                                │
│     데이터: List<MonthlyCategoryStat>                            │
│     역할: 월별 카테고리 통계 (그래프용)                          │
│                                                                   │
│  3️⃣ TransactionNotifier                                         │
│     데이터: List<TransactionModel>                               │
│     역할: 거래 데이터 + CRUD 처리                                │
│                                                                   │
└──────┬─────────────────────────┬─────────────────┬──────────────┘
       │                         │                 │
       └─────────┬───────────────┴───────┬─────────┘
                 │                       │
         자동 감시 체인             selectedMonthProvider
         (ref.watch)              (월 선택 상태)
                 │                       │
                 ↓                       ↓
        ┌─────────────────────────────────────┐
        │  Service Layer (DB 접근)           │
        ├──────────────────────────────────────┤
        │  StatService                        │
        │  TransactionService                 │
        │  UserEmotionService                 │
        └─────────────────────────────────────┘
```

---

## 🔄 자동 갱신 흐름

### 거래 추가 시

```
사용자 "저장" 클릭
    ↓
AddTransactionDialog
    └→ ref.read(transactionNotifierProvider.notifier)
           .addTransaction(transaction)
    ↓
TransactionNotifier.addTransaction()
    ├→ DB에 저장
    └→ transactionNotifierProvider 상태 변경
         (AsyncValue.loading → AsyncValue.data)
    ↓
[자동 감시 - ref.watch(transactionNotifierProvider)]
    ├→ CalendarStatNotifier.build() 재실행
    │   └→ calendarStatNotifierProvider 새로고침
    │       └→ Calendar 화면 자동 리빌드 ✅
    │
    └→ MonthlyCategoryStatsNotifier.build() 재실행
        └→ monthlyCategoryStatsNotifierProvider 새로고침
            └→ Statistics 화면 자동 리빌드 ✅
```

### 월 선택 변경 시

```
사용자 "< 이전 달" 버튼 클릭
    ↓
ref.read(selectedMonthProvider.notifier).state = newMonth
    ↓
selectedMonthProvider 상태 변경
    ↓
[자동 감시 - ref.watch(selectedMonthProvider)]
    └→ MonthlyCategoryStatsNotifier.build() 재실행
        └→ 새로운 월의 통계 데이터 로드
            └→ Statistics 화면 리빌드 ✅
```

---

## 📊 각 Notifier의 의존성

```
TransactionNotifier
    ↓
    └→ transactionNotifierProvider 상태 변경
        ↓
        ├→ CalendarStatNotifier가 ref.watch()로 감시
        │   └→ calendarStatNotifierProvider 새로고침
        │
        └→ MonthlyCategoryStatsNotifier가 ref.watch()로 감시
            └→ monthlyCategoryStatsNotifierProvider 새로고침


SelectedMonthProvider
    ↓
    └→ selectedMonthProvider 상태 변경
        ↓
        └→ MonthlyCategoryStatsNotifier가 ref.watch()로 감시
            └→ monthlyCategoryStatsNotifierProvider 새로고침
```

---

## 🎯 핵심 3가지

### ✅ 1. **Watch** (감시)

UI에서 데이터 변경을 감시할 때

```dart
ref.watch(calendarStatNotifierProvider)
```

### ✅ 2. **Read** (읽기)

한 번만 읽을 때, 또는 액션 수행할 때

```dart
ref.read(transactionNotifierProvider.notifier).addTransaction(...)
```

### ✅ 3. **Automatic Refresh** (자동 갱신)

Notifier 내부에서 ref.watch()로 의존성을 등록하면, 그 의존성이 변경될 때 자동으로 갱신됨

```dart
ref.watch(transactionNotifierProvider);  // 이 줄이 "감시"를 등록
// → transactionNotifierProvider 변경 시 build() 재실행
```

---

## 💭 "왜 복잡하게 느껴졌나?"

❌ **이전 구조 (복잡했던 이유)**

- StatefulWidget + 수동 setState + 여러 Future 호출
- 각 화면에서 개별적으로 데이터 관리
- 데이터 갱신이 일관성 없음

✅ **현재 구조 (단순함)**

- 3개 Notifier만 관리하면 됨
- 자동 갱신 체인 (거래 CRUD → 자동으로 캘린더/통계 새로고침)
- ConsumerWidget에서 ref.watch()만 하면 끝

---

## 🚀 마이그레이션 체크리스트

### Calendar 화면

- [ ] `StatefulWidget` → `ConsumerStatefulWidget` 변경
- [ ] `setState()` 제거
- [ ] `ref.watch(calendarStatNotifierProvider)` 추가
- [ ] 월 변경 시 `ref.read(calendarStatNotifierProvider.notifier).changeMonth()` 호출

### Statistics 화면

- [ ] `StatelessWidget` → `ConsumerWidget` 변경
- [ ] `ref.watch(monthlyCategoryStatsNotifierProvider)` 추가
- [ ] 월 선택 시 `ref.read(selectedMonthProvider.notifier).state = newMonth` 호출

### Add/Edit/Delete Transaction 화면

- [ ] `ConsumerWidget` 사용
- [ ] 저장 시 `ref.read(transactionNotifierProvider.notifier).addTransaction()`
- [ ] 수정 시 `ref.read(transactionNotifierProvider.notifier).updateTransaction()`
- [ ] 삭제 시 `ref.read(transactionNotifierProvider.notifier).deleteTransaction()`
- [ ] **자동 갱신되므로 추가 코드 불필요!**
