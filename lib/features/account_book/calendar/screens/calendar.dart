import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/widgets/calendar_cell.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/calendar_notifier.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends ConsumerStatefulWidget {
  const Calendar({super.key});

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  DateTime _focusedDay = todayKst();
  DateTime? _selectedDay;

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    // 월 변경시 데이터 새로고침
    ref.read(calendarStatNotifierProvider.notifier).changeMonth(focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    final statAsyncValue = ref.watch(calendarStatNotifierProvider);
    final focusedMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final emotionAsyncValue = ref.watch(emotionsByMonthProvider(focusedMonth));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: statAsyncValue.when(
          data: (statMap) {
            return emotionAsyncValue.when(
              data: (emotionMap) {
                return TableCalendar(
                  locale: 'en_US',
                  currentDay: todayKst(),
                  focusedDay: _focusedDay,

                  firstDay: DateTime(2025, 1, 1),
                  lastDay: DateTime(2035, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: _onPageChanged,
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {CalendarFormat.month: '월'},
                  rowHeight: 110,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: MainColors.mainDark,
                    ),
                    decoration: const BoxDecoration(color: Colors.white),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: MainColors.mainDark,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: MainColors.mainDark,
                    ),
                  ),
                  daysOfWeekHeight: 50,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    weekendStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    decoration: BoxDecoration(
                      color: MainColors.mainLight,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    cellMargin: const EdgeInsets.all(2),
                    defaultDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8EAF6)),
                    ),
                    todayDecoration: BoxDecoration(
                      color: MainColors.mainLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MainColors.mainLight,
                        width: 1.5,
                      ),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFF9FA8DA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    outsideDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8EAF6)),
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final stat =
                          statMap[DateTime(day.year, day.month, day.day)];
                      final emotion =
                          emotionMap[DateTime(day.year, day.month, day.day)];
                      return CalendarCell(
                        day: day,
                        stat: stat,
                        emotion: emotion,
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final stat =
                          statMap[DateTime(day.year, day.month, day.day)];
                      final emotion =
                          emotionMap[DateTime(day.year, day.month, day.day)];
                      return CalendarCell(
                        day: day,
                        stat: stat,
                        emotion: emotion,
                        isToday: true,
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final stat =
                          statMap[DateTime(day.year, day.month, day.day)];
                      final emotion =
                          emotionMap[DateTime(day.year, day.month, day.day)];
                      return CalendarCell(
                        day: day,
                        stat: stat,
                        emotion: emotion,
                        isSelected: true,
                      );
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      final stat =
                          statMap[DateTime(day.year, day.month, day.day)];
                      final emotion =
                          emotionMap[DateTime(day.year, day.month, day.day)];
                      return CalendarCell(
                        day: day,
                        stat: stat,
                        emotion: emotion,
                        isOutside: true,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text(FriendlyErrorMessage.of(error))),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text(FriendlyErrorMessage.of(error))),
        ),
      ),
    );
  }
}
