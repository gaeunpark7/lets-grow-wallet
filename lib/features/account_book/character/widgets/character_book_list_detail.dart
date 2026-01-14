import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

import '../model/character_book_item_model.dart';

class CharacterBookListDetail extends StatelessWidget {
  final CharacterBookItem item;

  const CharacterBookListDetail({super.key, required this.item});

  Widget _circleImage({
    required BuildContext context,
    required String imageUrl,
    required bool isUnlocked,
  }) {
    /// 캐릭터 도감/리스트에서 원형(ClipOval)으로 표시되는 캐릭터 썸네일 위젯을 렌더링합니다.
    ///
    /// 동작 요약:
    /// - 항상 60x60 크기의 원형 컨테이너를 생성합니다.
    /// - 배경색은 흰색(Colors.white)이며, [borderColor]로 테두리를 그립니다.
    /// - 중앙 정렬(Center)로 콘텐츠를 표시합니다.
    ///
    /// 잠금 여부([isUnlocked])에 따른 표시:
    /// - 잠금 해제된 경우:
    ///   - [imageUrl]이 비어있지 않으면 네트워크 이미지를 로드하여 표시합니다.
    ///     - 로딩된 이미지는 [BoxFit.contain]으로 컨테이너 안에 맞게 들어갑니다.
    ///     - 이미지 로드 실패 시(errorBuilder) `?` 문자를 [MainColors.mainLight] 색상으로 표시합니다.
    ///   - [imageUrl]이 비어있으면 `?` 문자를 [MainColors.mainLight] 색상으로 표시합니다.
    /// - 잠금 상태인 경우:
    ///   - 항상 `?` 문자를 [MainColors.mainDark] 색상으로 표시하여 잠금 상태임을 암시합니다.
    ///
    /// UI 의도:
    /// - 잠금 해제/이미지 유무/에러 상황에서도 일관되게 원형 자리표시자(`?`)가 보이도록 하여
    ///   레이아웃이 깨지지 않게 합니다.
    return ClipOval(
      child: Container(
        width: 70,
        height: 70,
        color: MainColors.main,
        child: Center(
          child: isUnlocked
              ? (imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, st) => Text(
                          '?',
                          style: TextStyle(
                            color: MainColors.mainLight,
                            fontSize: 22,
                          ),
                        ),
                      )
                    : Text(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eggUnlocked = true;
    final childUnlocked = item.hasChildUnlocked;
    final adultUnlocked = item.hasAdultUnlocked;

    final displayOpacity = item.isOwned ? 1.0 : 0.35;

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
          // ClipOval(
          //   child: Container(
          //     width: 100,
          //     height: 100,
          //     decoration: BoxDecoration(color: MainColors.main),
          //     child: Center(
          //       child: Opacity(
          //         opacity: displayOpacity,
          //         child: item.displayImageUrl.isNotEmpty
          //             ? Image.network(
          //                 item.displayImageUrl,
          //                 fit: BoxFit.contain,
          //                 errorBuilder: (ctx, err, st) => Text(
          //                   '?',
          //                   style: TextStyle(
          //                     color: MainColors.mainLight,
          //                     fontSize: 22,
          //                   ),
          //                 ),
          //               )
          //             : Text(
          //                 '?',
          //                 style: TextStyle(
          //                   color: MainColors.mainLight,
          //                   fontSize: 22,
          //                 ),
          //               ),
          //       ),
          //     ),
          //   ),
          // ),
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
