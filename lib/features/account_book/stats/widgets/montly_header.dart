import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/provider/stat_provider.dart';

class MonthHeader extends ConsumerWidget {
  final ValueChanged<StatsKind> onKindChanged;
  final StatsKind current;

  const MonthHeader({
    super.key,
    required this.onKindChanged,
    required this.current,
  });

  DateTime _addMonths(DateTime base, int delta) {
    final y = base.year + ((base.month + delta - 1) ~/ 12);
    final m = (base.month + delta - 1) % 12 + 1;
    return DateTime(y, m, 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final label = '${month.year}년 ${month.month}월';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => ref.read(selectedMonthProvider.notifier).state =
              _addMonths(month, -1),
          icon: const Icon(Icons.chevron_left),
        ),
        GestureDetector(
          onTap: () async {
            // MonthPicker 패키지로 교체 가능
          },
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(selectedMonthProvider.notifier).state =
              _addMonths(month, 1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
