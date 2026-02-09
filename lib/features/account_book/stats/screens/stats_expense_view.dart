import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/stats_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/category_chart_widget.dart';
import 'package:lets_grow_wallet/features/account_book/stats/widgets/category_state_tile.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';

class StatsExpenseView extends ConsumerWidget {
  const StatsExpenseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedMonthProvider);
    final asyncValue = ref.watch(monthlyCategoryStatsNotifierProvider);

    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        final error = FriendlyErrorMessage.resolve(e);
        return Center(child: Text(error.message));
      },
      data: (list) {
        final data = pickAmounts(list, StatsKind.expense);
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CategoryChartWidget(data: data),
                const Divider(),
                CategoryStatList(data: data),
              ],
            ),
          ),
        );
      },
    );
  }
}
