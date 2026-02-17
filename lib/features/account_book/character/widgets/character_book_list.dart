import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

import '../../model/character_book_item_model.dart';

class CharacterBookList extends StatefulWidget {
  final List<CharacterBookItem> items;
  final String? selectedCharacterId;
  final void Function(CharacterBookItem) onCharacterSelected;

  const CharacterBookList({
    super.key,
    required this.items,
    required this.selectedCharacterId,
    required this.onCharacterSelected,
  });

  @override
  State<CharacterBookList> createState() => _CharacterBookListState();
}

class _CharacterBookListState extends State<CharacterBookList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.wClamp),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.wClamp,
          mainAxisSpacing: 16.hClamp,
          childAspectRatio: 0.8, // 세로 길이 조절
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = item.characterId == widget.selectedCharacterId;
          final isBanHam = item.name.trim() == '반햄';
          final shouldShift = isBanHam && item.experience >= 300;

          final isUnduck = item.name.trim() == '언덕';
          final isAdultStage = item.hasAdultUnlocked;
          final isNotEggStage = item.hasChildUnlocked;

          final isFlowerDog = item.name.trim() == '꽃개';
          final isMungDog = item.name.trim() == '멍개';

          final shouldScaleUp = (isFlowerDog || isMungDog) && isNotEggStage;
          final shouldScaleUpUnDuck = isUnduck && isAdultStage;

          final double imageWidth = shouldScaleUpUnDuck
              ? 85.wClamp
              : (shouldScaleUp ? 80.wClamp : 70.wClamp);
          final double imageHeight = shouldScaleUpUnDuck
              ? 85.hClamp
              : (shouldScaleUp ? 80.hClamp : 70.hClamp);

          final opacity = item.isOwned ? 1.0 : 0.35;
          return GestureDetector(
            onTap: () {
              widget.onCharacterSelected(item);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? MainColors.mainLight : MainColors.main,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(100.rClamp),
                  bottom: Radius.circular(100.rClamp),
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: opacity,
                  child: item.displayImageUrl.isNotEmpty
                      ? Transform.translate(
                          offset: Offset(shouldShift ? -2.5.wClamp : 0, 0),
                          child: Image.network(
                            item.displayImageUrl,
                            width: imageWidth,
                            height: imageHeight,
                            // fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => const Text('?'),
                          ),
                        )
                      : Text(
                          '?',
                          style: TextStyle(
                            color: MainColors.mainLight,
                            fontSize: 22.spClamp,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
