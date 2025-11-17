import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterBookList extends StatefulWidget {
  final Function(int) onCharacterSelected;

  const CharacterBookList({super.key, required this.onCharacterSelected});

  @override
  State<CharacterBookList> createState() => _CharacterBookListState();
}

class _CharacterBookListState extends State<CharacterBookList> {
  int seletedIndex = 0;

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
        itemCount: 6,
        itemBuilder: (context, index) {
          final isSeleted = index == seletedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                seletedIndex = index;
              });
              widget.onCharacterSelected(index);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                color: isSeleted ? MainColors.mainLight : MainColors.main,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(100),
                  bottom: Radius.circular(100),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
