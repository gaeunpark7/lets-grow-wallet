import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class CharacterPageCharacter extends StatelessWidget {
  final String imageUrl;
  final String backgroundUrl;
  final String characterName;
  final bool isEggStage;

  const CharacterPageCharacter({
    super.key,
    required this.imageUrl,
    this.backgroundUrl = '',
    this.characterName = '',
    this.isEggStage = false,
  });

  @override
  Widget build(BuildContext context) {
    //반햄 일때(알 x) 약간 왼쪽을 이동
    final isBanHam = characterName.trim() == '반햄';
    final shouldShift = isBanHam && !isEggStage;

    //꽃개 일때(알 x) 크기 키우기, 너무 내려가 보일 수 있어서, 살짝 덜 내림
    final isFlowerDog = characterName.trim() == '꽃개';
    final shouldScaleUpFlowerDog = isFlowerDog && !isEggStage;
    final double characterWidth = (shouldScaleUpFlowerDog ? 200 : 160).wClamp;
    final double translateY = (shouldScaleUpFlowerDog ? 58 : 70).rClamp;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          //배경 이미지
          Image.network(
            backgroundUrl,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
          //캐릭터 이미지
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(shouldShift ? -5.wClamp : 0, translateY),
              child: Image.network(
                imageUrl,
                width: characterWidth,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      child,
                      SizedBox(
                        width: 24.rClamp,
                        height: 24.rClamp,
                        child: const CircularProgressIndicator(
                          color: MainColors.mainLight,
                        ),
                      ),
                    ],
                  );
                },

                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.pets,
                    size: 100.rClamp,
                    color: Colors.grey[400],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
