import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CalendarDesign extends StatefulWidget {
  final Widget? child;
  const CalendarDesign({super.key, this.child});

  @override
  State<CalendarDesign> createState() => _CalendarDesignState();
}

class _CalendarDesignState extends State<CalendarDesign> {
  @override
  Widget build(BuildContext context) {
    Color? dayTextColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.selected))
        return Colors.white; // 선택 날짜 텍스트
      return MainColors.mainDark; // 기본 날짜 텍스트
    }

    Color? yearTextColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.selected))
        return Colors.white; // 선택 년도 텍스트
      return MainColors.mainDark; // 기본 년도 텍스트
    }

    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: MainColors.mainLight, // 선택된 날짜(원) / 년도 선택 배경
          onPrimary: Colors.white, // 선택된 (날짜/년도) 텍스트 색
          surface: Colors.white,
          onSurface: MainColors.mainDark,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MainColors.mainDark, // 취소/확인
          ),
        ),
        datePickerTheme: const DatePickerThemeData().copyWith(
          backgroundColor: Colors.white,
          headerBackgroundColor: MainColors.mainLight,
          headerForegroundColor: Colors.white,

          dayForegroundColor: WidgetStateProperty.resolveWith(dayTextColor),
          weekdayStyle: const TextStyle(color: MainColors.mainDark),
          dayStyle: const TextStyle(color: MainColors.mainDark),

          todayForegroundColor: const WidgetStatePropertyAll(
            MainColors.mainLight,
          ),
          todayBorder: const BorderSide(
            color: MainColors.mainLight,
            width: 1.5,
          ),

          yearForegroundColor: WidgetStateProperty.resolveWith(yearTextColor),
          yearStyle: const TextStyle(color: MainColors.mainDark),
        ),
      ),
      child: widget.child!,
    );
  }
}
