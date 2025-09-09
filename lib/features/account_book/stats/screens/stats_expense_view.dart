import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/provider/stat_provider.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/category_chart_widget.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/category_state_tile.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/stats_ai_message.dart';

class StatsExpenseView extends ConsumerWidget {
  const StatsExpenseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final asyncValue = ref.watch(monthlyCategoryStatsProvider(month));

    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('에러: $e')),
      data: (list) {
        final data = pickAmounts(list, StatsKind.expense);
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                StatsAIMessage(),
                CategoryChartWidget(data: data),
                Divider(),
                CategoryStatList(data: data),
              ],
            ),
          ),
        );
      },
    );
  }
}
