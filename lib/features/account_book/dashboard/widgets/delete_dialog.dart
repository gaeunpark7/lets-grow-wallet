import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class DeleteDialog extends StatelessWidget {
  VoidCallback onTap;
  DeleteDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Text(
              "정말로 이 내역을 삭제하시겠습니까?",
              style: TextStyle(fontSize: 16, color: MainColors.mainDark),
            ),
            SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: MainColors.mainDark,
                      backgroundColor: MainColors.main,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "취소",
                      style: TextStyle(color: MainColors.mainDark),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: MainColors.mainLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      onTap();
                    },
                    child: Text("삭제"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
