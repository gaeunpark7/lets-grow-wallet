import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/calender/model/daily_stat_model.dart';
import 'package:lets_grow_wallet/features/account_book/calender/services/stat_service.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DailyStat? _stat;

  // DailyStat _stat; //선택된 날짜의 통계

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _stat = null; //로딩 전 초기화
    });
    final stat = await StatService().fetchDailyStat(selectedDay);
    setState(() {
      _stat = stat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text("캘린더")),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: TableCalendar(
              calendarBuilders: CalendarBuilders(),
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: onDaySelected,
              calendarFormat: CalendarFormat.month, //월간 보기로 고정
              availableCalendarFormats: const {CalendarFormat.month: '월'},
              rowHeight: 60, //셀 크기
              //style
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 171, 197),
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 171, 197),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 176, 255),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                // color: Color(0xFFF5F5F5),
                // borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 0.2),
              ),
              child: _stat == null
                  ? Center(child: Text("거래내역이 없습니다."))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_selectedDay?.year}년 ${_selectedDay?.month}월 ${_selectedDay?.day}일",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "총 수입: +${_stat!.totalIncome}원",
                            style: TextStyle(),
                          ),
                          Text(
                            "총 지출: -${_stat!.totalExpense}원",
                            style: TextStyle(),
                          ),
                          Text("현금 지출: ${_stat!.cashExpense}원"),
                          Text("카드 지출: ${_stat!.cardExpense}원"),
                          const SizedBox(height: 10),
                          Divider(),
                          Text(
                            "남은 금액: ${_stat!.totalIncome - _stat!.totalExpense}원",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("테스트"),
                          Text("테스트"),
                          Text("테스트"),
                          Text("테스트"),
                          Text("테스트"),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
