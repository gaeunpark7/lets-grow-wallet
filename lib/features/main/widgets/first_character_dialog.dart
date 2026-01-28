import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class FirstCharacterDialog extends StatelessWidget {
  const FirstCharacterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "캐릭터 획득",
                style: TextStyle(
                  fontSize: 18,
                  color: MainColors.mainDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5),
            Divider(color: MainColors.mainLight, thickness: 1.5, height: 0),
            SizedBox(height: 12),

            Image.asset(
              'assets/ad/flower_dog1_happy.png',
              fit: BoxFit.contain,
              width: 120,
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: MainColors.mainLight,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "확인",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
