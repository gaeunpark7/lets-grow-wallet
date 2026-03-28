import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

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
        padding: EdgeInsets.all(16.wClamp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: MainColors.point, size: 40.hClamp),
            SizedBox(height: 12.hClamp),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: MainColors.mainDark),
            ),
            SizedBox(height: 16.hClamp),
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
                SizedBox(width: 10.wClamp),
                OutlinedButton(
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MainColors.mainDark,
                    side: BorderSide(color: MainColors.mainDark),
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
