import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterBookListDetail extends StatefulWidget {
  const CharacterBookListDetail({super.key});

  @override
  State<CharacterBookListDetail> createState() =>
      _CharacterBookListDetailState();
}

class _CharacterBookListDetailState extends State<CharacterBookListDetail> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 1,
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCharacterDetail(),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: MainColors.mainDark),
                SizedBox(width: 12),
                _buildCharacterDetail(),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: MainColors.mainDark),
                SizedBox(width: 12),
                _buildCharacterDetail(),
              ],
            ),
            ClipOval(
              child: Container(width: 100, height: 100, color: MainColors.main),
            ),
            ClipOval(
              child: Container(width: 100, height: 100, color: MainColors.main),
            ),
            SizedBox(height: 12),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: MainColors.mainLight),
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 80, // SizedBox(height: 24),

              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: MainColors.mainLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildCharacterDetail() {
    return ClipOval(
      child: Container(width: 60, height: 60, color: MainColors.mainLight),
    );
  }
}
