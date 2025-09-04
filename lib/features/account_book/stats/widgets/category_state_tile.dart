import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryStatList extends StatelessWidget {
  final List<({String id, String name, int amount})> data;

  const CategoryStatList({super.key, required this.data});

  static const _palette = <Color>[
    Color(0xFFEF5350),
    Color(0xFFFFA726),
    Color(0xFFFFEE58),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
  ];

  Color _colorFor(String id) {
    final h = id.codeUnits.fold<int>(0, (p, c) => p + c);
    return _palette[h % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (p, e) => p + e.amount);
    final f = NumberFormat.decimalPattern('ko');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, idx) {
        final e = data[idx];
        final percent = total == 0 ? 0 : (e.amount / total * 100).round();
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // 퍼센트와 색상 박스
              Container(
                width: 40,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _colorFor(e.id).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$percent%",
                  style: TextStyle(
                    color: _colorFor(e.id),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 아이콘/이모지
              // Text(
              //   _emojiForCategory(e.name),
              //   style: const TextStyle(fontSize: 22),
              // ),
              // const SizedBox(width: 8),
              // 카테고리
              Expanded(
                child: Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // 금액
              Text(
                "${f.format(e.amount)}원",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 카테고리 이모지
  String _emojiForCategory(String name) {
    if (name.contains("카페")) return "☕";
    if (name.contains("교육")) return "📚";
    if (name.contains("문화")) return "🖼️";
    // 기본값
    return "💸";
  }
}
