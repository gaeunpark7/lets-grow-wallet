import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class MyPageErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const MyPageErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: MainColors.point, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: MainColors.mainDark),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MainColors.mainLight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('다시 시도'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MainColors.mainDark,
                    side: const BorderSide(color: MainColors.mainDark),
                  ),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
