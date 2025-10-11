import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        top: BorderSide(color: MainColors.point, width: 1),
        bottom: BorderSide(color: MainColors.point, width: 1),
        verticalInside: BorderSide(color: MainColors.point, width: 1),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1), // 날짜
        1: FlexColumnWidth(3.5), // 내역
        2: FlexColumnWidth(2.5), // 지출
        3: FlexColumnWidth(1), // 카드
        4: FlexColumnWidth(1), // 현금
      },
      children: [
        TableRow(
          children: [
            _buildHeaderCell("날짜"),
            _buildHeaderCell("내역"),
            _buildHeaderCell("금액"),
            _buildHeaderCell("카드"),
            _buildHeaderCell("현금"),
          ],
        ),
      ],
    );
  }
}

Widget _buildHeaderCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, color: MainColors.mainDark),
    ),
  );
}
