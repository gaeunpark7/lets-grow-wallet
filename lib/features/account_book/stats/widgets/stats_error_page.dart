import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class StatsErrorPage extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  const StatsErrorPage({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: MainColors.point, size: 40.hClamp),
          SizedBox(height: 12.hClamp),
          Text(
            errorMessage,
            style: const TextStyle(color: MainColors.mainDark),
          ),
          SizedBox(height: 12.hClamp),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: MainColors.mainLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
