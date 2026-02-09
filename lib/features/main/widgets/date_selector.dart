import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('yyyy.MM.dd (E)', 'ko').format(selectedDate);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainDark, width: 0.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
              // const SizedBox(width: 8),
              Text(
                dateString,
                style: const TextStyle(
                  fontSize: 16,
                  color: MainColors.mainDark,
                ),
              ),
              // const SizedBox(width: 8),
              // const Icon(Icons.arrow_drop_down, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
