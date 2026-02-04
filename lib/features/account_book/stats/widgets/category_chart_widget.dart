import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class CategoryChartWidget extends StatelessWidget {
  final List<({String id, String name, int amount})> data;

  const CategoryChartWidget({super.key, required this.data});

  static const _palette = <Color>[
    // Color.fromARGB(255, 92, 105, 172),
    Color(0xFF7986CB),
    Color(0xFF9FA8DA),
    Color(0xFFC5CAE9),
    Color(0xFFE8EAF6),
    Color(0xFFF5F5FA),
    Color.fromARGB(255, 139, 192, 217),

    Color(0xFFB3E5FC),
    Color(0xFFB2DFDB),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
    Color(0xFFFFE4B5),
    Color.fromARGB(255, 255, 238, 238),
  ];

  Color _colorForIndex(int idx) => _palette[idx % _palette.length];

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (p, e) => p + e.amount);

    if (data.isEmpty || total == 0) {
      return SizedBox(
        height: 320.hClamp,
        child: Center(
          child: Text(
            '데이터가 없어요.',
            style: TextStyle(color: MainColors.mainDark),
          ),
        ),
      );
    }

    // 퍼센트 내림차순 정렬
    final sorted = [...data];
    sorted.sort((a, b) => b.amount.compareTo(a.amount));

    // 차트 크기 키우기
    final chartSize = 320.0.hClamp;
    final pieRadius = 120.0.hClamp;
    final center = Offset(chartSize / 2, chartSize / 2);
    final labelRadius = pieRadius + 24; // 라벨 위치 반지름

    // 파이 섹션 데이터
    final sections = List.generate(sorted.length, (i) {
      final e = sorted[i];
      return PieChartSectionData(
        value: e.amount.toDouble(),
        title: '',
        radius: pieRadius,
        color: _colorForIndex(i),
      );
    });

    // 각 섹션의 중간 각도 계산
    double startAngle = -pi / 2;
    final midAngles = <double>[];
    for (final e in sorted) {
      final sweep = total == 0 ? 0.0 : (e.amount / total) * 2 * pi;
      final mid = startAngle + sweep / 2;
      midAngles.add(mid);
      startAngle += sweep;
    }

    return SizedBox(
      height: chartSize,
      width: chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 0,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
          // 퍼센트 라벨 바깥에 배치 - 가운데 정렬
          ...List.generate(sorted.length, (i) {
            final e = sorted[i];
            final percent = total == 0 ? 0.0 : (e.amount / total * 100);
            if (percent < 6) return const SizedBox.shrink();
            final angle = midAngles[i];
            final dx = center.dx + labelRadius * cos(angle);
            final dy = center.dy + labelRadius * sin(angle);
            return Positioned(
              left: dx - 24, // 가운데 정렬 (텍스트 폭의 절반만큼 빼줌)
              top: dy - 14,
              child: SizedBox(
                width: 48.wClamp,
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.sp, color: MainColors.mainDark),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
