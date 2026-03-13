import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

import '../../model/character_book_item_model.dart';

class CharacterBookListDetail extends StatelessWidget {
  final CharacterBookItem item;

  const CharacterBookListDetail({super.key, required this.item});

  Widget _circleImage({
    required BuildContext context,
    required String imageUrl,
    required bool isUnlocked,
    required String stage,
  }) {
    final name = item.name.trim();
    final isUnduck = name == '언덕';
    final isBanHam = name == '반햄';
    final shouldShift = isBanHam && stage != 'egg';
    final
    // 원형 유지, 컨테이너 크기 조절 > 이미지 크기 조절
    double
    padding = isUnduck
        ? (stage == 'adult'
              ? 4.wClamp
              : (stage == 'child' ? 12.wClamp : 8.wClamp))
        : 8.wClamp;

    return ClipOval(
      child: Container(
        width: 70,
        height: 70,
        color: MainColors.main,
        child: Center(
          child: isUnlocked
              ? (imageUrl.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.all(padding),
                        child: Transform.translate(
                          offset: Offset(shouldShift ? -1.wClamp : 0, 0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, st) => Text(
                              //이미지 로드 실패
                              '?',
                              style: TextStyle(
                                color: MainColors.mainLight,
                                fontSize: 22.spClamp,
                                fontFamily: 'ScoreMedium',
                              ),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        //잠금 상태
                        '?',
                        style: TextStyle(
                          color: MainColors.mainLight,
                          fontSize: 22.spClamp,
                          fontFamily: 'ScoreMedium',
                        ),
                      ))
              : Text(
                  '?',
                  style: TextStyle(
                    color: MainColors.mainDark,
                    fontFamily: 'ScoreMedium',
                    fontSize: 22.spClamp,
                  ),
                ),
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
      padding: EdgeInsets.all(12.wClamp),
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
                stage: 'egg',
              ),
              _buildIntroArrow(),
              _circleImage(
                context: context,
                imageUrl: item.childImageUrl,
                isUnlocked: childUnlocked,
                stage: 'child',
              ),
              _buildIntroArrow(),
              _circleImage(
                context: context,
                imageUrl: item.adultImageUrl,
                isUnlocked: adultUnlocked,
                stage: 'adult',
              ),
            ],
          ),
          SizedBox(height: 12.hClamp),
          _buildIntro(context, 40.hClamp, item.name),
          SizedBox(height: 12.hClamp),
          _buildIntro(context, 80.hClamp, item.description),
        ],
      ),
    );
  }

  _buildIntroArrow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.wClamp),
      child: Icon(
        Icons.arrow_forward,
        color: MainColors.mainDark,
        size: 28.rClamp,
      ),
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
        padding: EdgeInsets.all(8.0.wClamp),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.spClamp,
            color: MainColors.mainDark,
            fontFamily: 'ScoreMedium',
          ),
        ),
      ),
    );
  }
}
