import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

import '../../model/character_book_item_model.dart';

class CharacterBookListDetail extends StatelessWidget {
  final CharacterBookItem item;

  const CharacterBookListDetail({super.key, required this.item});

  Widget _circleImage({
    required BuildContext context,
    required String imageUrl,
    required bool isUnlocked,
  }) {
    return Container(
      width: 70,
      height: 70,
      color: MainColors.main,
      child: Center(
        child: isUnlocked
            ? (imageUrl
                      .isNotEmpty // 잠금 해제된 경우
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => Text(
                        //이미지 로드 실패
                        '?',
                        style: TextStyle(
                          color: MainColors.mainLight,
                          fontSize: 22,
                        ),
                      ),
                    )
                  : Text(
                      //잠금 상태
                      '?',
                      style: TextStyle(
                        color: MainColors.mainLight,
                        fontSize: 22,
                      ),
                    ))
            : Text(
                '?',
                style: TextStyle(color: MainColors.mainDark, fontSize: 22),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eggUnlocked = true;
    final childUnlocked = item.hasChildUnlocked;
    final adultUnlocked = item.hasAdultUnlocked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: MainColors.mainLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleImage(
                context: context,
                imageUrl: item.eggImageUrl,
                isUnlocked: eggUnlocked,
              ),
              _buildIntroArrow(),
              _circleImage(
                context: context,
                imageUrl: item.childImageUrl,
                isUnlocked: childUnlocked,
              ),
              _buildIntroArrow(),
              _circleImage(
                context: context,
                imageUrl: item.adultImageUrl,
                isUnlocked: adultUnlocked,
              ),
            ],
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 12),
          _buildIntro(context, 40, item.name),
          const SizedBox(height: 12),
          _buildIntro(context, 80, item.description),
        ],
      ),
    );
  }

  _buildIntroArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(Icons.arrow_forward, color: MainColors.mainDark, size: 28),
    );
  }

  _buildIntro(BuildContext context, double height, String text) {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: MainColors.mainLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: MainColors.mainDark),
        ),
      ),
    );
  }
}
