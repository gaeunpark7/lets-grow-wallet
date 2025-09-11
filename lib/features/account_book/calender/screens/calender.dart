import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/stat_service.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, DailyStat> _statMap = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final Map<DateTime, DailyStat> temp = {};

    for (int i = 0; i < lastDay.day; i++) {
      final day = DateTime(firstDay.year, firstDay.month, i + 1);
      final stat = await StatService().fetchDailyStat(day); // DailyStat? 리턴
      if (stat != null) {
        temp[stat.day] = stat;
      }
    }

    setState(() {
      _statMap = temp;
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
              return _CalendarCell(day: day, stat: stat);
            },
            todayBuilder: (context, day, focusedDay) {
              final stat = _statMap[DateTime(day.year, day.month, day.day)];
              return _CalendarCell(day: day, stat: stat, isToday: true);
            },
            selectedBuilder: (context, day, focusedDay) {
              final stat = _statMap[DateTime(day.year, day.month, day.day)];
              return _CalendarCell(day: day, stat: stat, isSelected: true);
            },
            outsideBuilder: (context, day, focusedDay) {
              final stat = _statMap[DateTime(day.year, day.month, day.day)];
              return _CalendarCell(day: day, stat: stat, isOutside: true);
            },
          ),
        ),
      ),
    );
  }
}

// 날짜 셀 커스텀 위젯
class _CalendarCell extends StatelessWidget {
  final DateTime day;
  final DailyStat? stat;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  const _CalendarCell({
    required this.day,
    this.stat,
    this.isToday = false,
    this.isSelected = false,
    this.isOutside = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isOutside ? Colors.grey[300] : MainColors.mainDark;

    return SizedBox(
      height: 110,
      width: 110,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF9FA8DA)
              : isToday
              ? const Color(0xFFF5F5FA)
              : Colors.white,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: Color(0xFFE8EAF6)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (stat != null) ...[
              // 이모티콘 영역 (추후 추가)
              Icon(Icons.mood_outlined, color: MainColors.mainLight),
              SizedBox(height: 5),
              if (stat!.totalExpense != 0)
                Text(
                  '- ${stat!.totalExpense}',
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                ),
              if (stat!.totalIncome != 0)
                Text(
                  '+${stat!.totalIncome}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7986CB),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
