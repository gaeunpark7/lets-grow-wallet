import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class DeleteUserDialog extends StatelessWidget {
  const DeleteUserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '회원탈퇴',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '정말 탈퇴하시겠어요?\n삭제된 계정은 복구할 수 없습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildSelectButton(
                  context,
                  const Color.fromARGB(255, 245, 245, 245),
                  Colors.grey,
                  '취소',
                  () {
                    Navigator.pop(context, false);
                  },
                ),
                SizedBox(width: 8),
                _buildSelectButton(
                  context,
                  MainColors.mainLight,
                  Colors.white,
                  '탈퇴',
                  () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildSelectButton(
    BuildContext context,
    Color backColor,
    Color textColor,
    String text,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: backColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}
