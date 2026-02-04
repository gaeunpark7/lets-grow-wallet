import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterActionBottomBar extends StatefulWidget {
  final ValueChanged<InteractionType>? onInteraction;

  const CharacterActionBottomBar({super.key, this.onInteraction});

  @override
  State<CharacterActionBottomBar> createState() =>
      _CharacterActionBottomBarState();
}

class _CharacterActionBottomBarState extends State<CharacterActionBottomBar> {
  bool _showActions = false;
  OverlayEntry? _actionsOverlay;

  @override
  void dispose() {
    _hideActions();
    super.dispose();
  }

  void _toggleActions() {
    if (_showActions) {
      _hideActions();
    } else {
      _showActionsOverlay();
    }
  }

  void _showActionsOverlay() {
    if (_actionsOverlay != null) return;

    setState(() {
      _showActions = true;
    });

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _actionsOverlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 바깥을 누르면 닫기
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideActions,
                  child: const SizedBox.expand(),
                ),
              ),

              Positioned(
                left: 90,
                bottom: 70 + 10,
                child: _actionButton(
                  "먹이주기",
                  () => widget.onInteraction?.call(InteractionType.feed),
                ),
              ),
              Positioned(
                left: 145,
                bottom: 70 + 50,
                child: _actionButton(
                  "놀아주기",
                  () => widget.onInteraction?.call(InteractionType.play),
                ),
              ),
              Positioned(
                right: 145,
                bottom: 70 + 50,
                child: _actionButton(
                  "쓰다듬기",
                  () => widget.onInteraction?.call(InteractionType.pet),
                ),
              ),
              Positioned(
                right: 90,
                bottom: 70 + 10,
                child: _actionButton(
                  "혼자두기",
                  () => widget.onInteraction?.call(InteractionType.idle),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_actionsOverlay!);
  }

  void _hideActions() {
    _actionsOverlay?.remove();
    _actionsOverlay = null;
    if (mounted) {
      setState(() {
        _showActions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // 바텀
        Container(height: 70, color: MainColors.mainLight),

        // 메인 버튼
        Positioned(
          bottom: 30,
          child: GestureDetector(
            onTap: _toggleActions,
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

  Widget _actionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        _hideActions();
      },
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: MainColors.mainLight, width: 1.2),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: MainColors.mainDark),
          ),
        ),
      ),
    );
  }
}
