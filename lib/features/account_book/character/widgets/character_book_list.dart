import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

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
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.8, // 세로 길이 조절
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = item.characterId == widget.selectedCharacterId;

          final opacity = item.isOwned ? 1.0 : 0.35;
          return GestureDetector(
            onTap: () {
              widget.onCharacterSelected(item);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                color: isSelected ? MainColors.mainLight : MainColors.main,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(100),
                  bottom: Radius.circular(100),
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: opacity,
                  child: item.displayImageUrl.isNotEmpty
                      ? Image.network(
                          item.displayImageUrl,
                          width: MediaQuery.of(context).size.width * 0.17,
                          height: MediaQuery.of(context).size.height * 0.16,
                          // fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => const Text('?'),
                        )
                      : Text(
                          '?',
                          style: TextStyle(
                            color: MainColors.mainLight,
                            fontSize: 22,
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
