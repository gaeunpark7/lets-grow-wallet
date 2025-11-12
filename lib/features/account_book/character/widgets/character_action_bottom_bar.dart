import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterActionBottomBar extends StatefulWidget {
  const CharacterActionBottomBar({super.key});

  @override
  State<CharacterActionBottomBar> createState() =>
      _CharacterActionBottomBarState();
}

class _CharacterActionBottomBarState extends State<CharacterActionBottomBar> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // 바텀
        Container(height: 70, color: MainColors.mainLight),

        // 행동 버튼
        if (_showActions) ...[
          Positioned(left: 90, bottom: 80, child: _actionButton("먹이주기")),
          Positioned(left: 145, bottom: 120, child: _actionButton("놀아주기")),
          Positioned(right: 145, bottom: 120, child: _actionButton("쓰다듬기")),
          Positioned(right: 90, bottom: 80, child: _actionButton("혼자두기")),
        ],

        // 메인 버튼
        Positioned(
          bottom: 30,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showActions = !_showActions;
              });
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MainColors.main,
              ),
              child: const Center(
                child: Icon(Icons.pets, color: MainColors.mainLight, size: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String text) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 0.8),
      ),
      child: Center(child: Text(text, style: const TextStyle(fontSize: 12))),
    );
  }
}
