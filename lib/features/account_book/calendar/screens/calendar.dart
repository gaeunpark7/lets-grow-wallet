import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/widgets/calendar_cell.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/screens/calendar_detail.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/calendar_notifier.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/kst_time.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends ConsumerStatefulWidget {
  const Calendar({super.key});

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  DateTime _focusedDay = todayKst();
  DateTime? _selectedDay;

  Future<void> _openDetailDialog(DateTime day) async {
    await showDialog(
      context: context,
      builder: (ctx) => CalendartDetail(selectedDate: day),
    );

    // 다이얼로그에서 감정/수입/지출이 변경될 수 있으므로 닫힌 뒤 갱신
    if (!mounted) return;
    final month = DateTime(day.year, day.month, 1);
    ref.invalidate(emotionsByMonthProvider(month));
    ref.read(calendarStatNotifierProvider.notifier).refreshDailyStats();
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    // 월 변경시 데이터 새로고침
    ref.read(calendarStatNotifierProvider.notifier).changeMonth(focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        // systemNavigationBarColor: MainColors.mainLight,
      ),
    );
    final statAsyncValue = ref.watch(calendarStatNotifierProvider);
    final focusedMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final emotionAsyncValue = ref.watch(emotionsByMonthProvider(focusedMonth));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            Widget fullHeightCenter(Widget child) {
              return SizedBox(
                height: constraints.maxHeight,
                child: Center(child: child),
              );
            }

            //에러 처리
            Widget fullHeightErrorWithRetry({
              required Object error,
              required VoidCallback onRetry,
            }) {
              return SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: MainColors.point,
                        size: 40.hClamp,
                      ),
                      SizedBox(height: 12.hClamp),
                      Text(
                        FriendlyErrorMessage.of(error),
                        style: TextStyle(
                          color: MainColors.mainDark,
                          // fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.hClamp),
                      FilledButton(
                        onPressed: onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: MainColors.mainLight,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: statAsyncValue.when(
                data: (statMap) {
                  return emotionAsyncValue.when(
                    data: (emotionMap) {
                      return TableCalendar(
                        locale: 'en_US',
                        currentDay: todayKst(),
                        focusedDay: _focusedDay,
                        firstDay: DateTime(2025, 12, 1),
                        lastDay: DateTime(2035, 12, 31),
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: _onPageChanged,
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: '월',
                        },
                        rowHeight: 110.hClamp,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          headerPadding: EdgeInsets.zero,
                          titleTextStyle: TextStyle(
                            fontSize: 23.spClamp,
                            fontWeight: FontWeight.bold,
                            color: MainColors.mainDark,
                            fontFamily: 'ScoreBold',
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
                        daysOfWeekHeight: 50.hClamp,
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 15.spClamp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            fontFamily: 'ScoreMedium',
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 15.spClamp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            fontFamily: 'ScoreMedium',
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
                                emotionMap[DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                )];
                            return CalendarCell(
                              day: day,
                              stat: stat,
                              emotion: emotion,
                              onTap: () => _openDetailDialog(day),
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            final stat =
                                statMap[DateTime(day.year, day.month, day.day)];
                            final emotion =
                                emotionMap[DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                )];
                            return CalendarCell(
                              day: day,
                              stat: stat,
                              emotion: emotion,
                              isToday: true,
                              onTap: () => _openDetailDialog(day),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            final stat =
                                statMap[DateTime(day.year, day.month, day.day)];
                            final emotion =
                                emotionMap[DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                )];
                            return CalendarCell(
                              day: day,
                              stat: stat,
                              emotion: emotion,
                              isSelected: true,
                              onTap: () => _openDetailDialog(day),
                            );
                          },
                          outsideBuilder: (context, day, focusedDay) {
                            final stat =
                                statMap[DateTime(day.year, day.month, day.day)];
                            final emotion =
                                emotionMap[DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                )];
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
                    loading: () => fullHeightCenter(
                      const CircularProgressIndicator(
                        color: MainColors.mainLight,
                      ),
                    ),
                    error: (error, stack) => fullHeightErrorWithRetry(
                      error: error,
                      onRetry: () {
                        ref.invalidate(emotionsByMonthProvider(focusedMonth));
                      },
                    ),
                  );
                },
                loading: () => fullHeightCenter(
                  CircularProgressIndicator(color: MainColors.mainLight),
                ),
                error: (error, stack) => fullHeightErrorWithRetry(
                  error: error,
                  onRetry: () {
                    final month = DateTime(
                      _focusedDay.year,
                      _focusedDay.month,
                      1,
                    );
                    ref
                        .read(calendarStatNotifierProvider.notifier)
                        .changeMonth(month);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
