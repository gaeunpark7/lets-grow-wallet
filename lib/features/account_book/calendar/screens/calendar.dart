import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/calendar/widgets/calendar_cell.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, DailyStat> _statMap = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final statMap = await StatService().fetchDailyStatsForMonth(_focusedDay);
    setState(() {
      _statMap = statMap;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: TableCalendar(
          locale: 'en_US', //요일 앞글자
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
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
          rowHeight: 110, // 셀 크기 키움
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
          //요일 디자인
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
              color: MainColors.mainLight, // 배경색
              borderRadius: BorderRadius.zero,
            ),
          ),
          //
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(2),
            defaultDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE8EAF6)),
            ),
            //오늘 날짜 옵션
            todayDecoration: BoxDecoration(
              color: MainColors.mainLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MainColors.mainLight, width: 1.5),
            ),
            //선택한 날짜 옵션
            selectedDecoration: BoxDecoration(
              color: Color(0xFF9FA8DA),
              borderRadius: BorderRadius.circular(8),
            ),
            outsideDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE8EAF6)),
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final stat = _statMap[DateTime(day.year, day.month, day.day)];
              return CalendarCell(day: day, stat: stat);
            },
            todayBuilder: (context, day, focusedDay) {
              final stat = _statMap[DateTime(day.year, day.month, day.day)];
              return CalendarCell(day: day, stat: stat, isToday: true);
            },
            selectedBuilder: (context, day, focusedDay) {
              final stat = _statMap[DateTime(day.year, day.month, day.day)];
              return CalendarCell(day: day, stat: stat, isSelected: true);
            },
            outsideBuilder: (context, day, focusedDay) {
              final stat = _statMap[DateTime(day.year, day.month, day.day)];
              return CalendarCell(day: day, stat: stat, isOutside: true);
            },
          ),
        ),
      ),
    );
  }
}
