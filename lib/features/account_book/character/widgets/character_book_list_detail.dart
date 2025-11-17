import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/character/model/character_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterBookListDetail extends StatefulWidget {
  final int selectedCharacterIndex;
  final List<Character> characters;
  const CharacterBookListDetail({
    super.key,
    required this.selectedCharacterIndex,
    required this.characters,
  });

  @override
  State<CharacterBookListDetail> createState() =>
      _CharacterBookListDetailState();
}

class _CharacterBookListDetailState extends State<CharacterBookListDetail> {
  int selectedCircleIndex = -1;

  @override
  Widget build(BuildContext context) {
    final selectedCharacter = widget.characters[widget.selectedCharacterIndex];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: MainColors.mainLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              if (i.isEven) {
                final index = i ~/ 2;
                final isSelected = selectedCircleIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCircleIndex = index;
                    });
                  },
                  child: ClipOval(
                    child: Container(
                      width: 60,
                      height: 60,
                      color: isSelected
                          ? MainColors.mainLight
                          : MainColors.main,
                    ),
                  ),
                );
              } else {
                // 화살표 아이콘
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_forward,
                    color: MainColors.mainDark,
                    size: 28,
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 12),
          ClipOval(
            child: Container(width: 100, height: 100, color: MainColors.main),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: MainColors.mainLight),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    selectedCharacter.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: MainColors.mainDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: MainColors.mainLight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                selectedCharacter.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: MainColors.mainDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
