import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

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
  final LayerLink _actionLink = LayerLink();

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
        final actionButtonSize = 60.rClamp;
        final gapX = 10.wClamp;
        final gapY = 10.hClamp;
        final outerExtraDx = 14.wClamp; // 먹이주기/혼자두기 좌우 더 벌리기
        final outerExtraDownDy = 12.hClamp; // 먹이주기/혼자두기만 더 아래로
        final overlayGapToMainButton = 60.hClamp; //버튼 클릭시 오버레이와 메인 버튼 사이 간격

        final outerDx = actionButtonSize + gapX + outerExtraDx; // 좌/우 끝 버튼
        final innerDx = (actionButtonSize / 2) + (gapX / 2); // 위쪽 버튼
        final lowDy = (actionButtonSize / 2) + gapY; // 아래쪽 버튼 높이
        final highDy = actionButtonSize + (gapY * 2); // 위쪽 버튼 높이

        final clusterWidth = (outerDx * 2) + actionButtonSize;
        final clusterHeight = highDy + actionButtonSize;

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideActions,
                  child: const SizedBox.expand(),
                ),
              ),
              CompositedTransformFollower(
                link: _actionLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.topCenter,
                followerAnchor: Alignment.bottomCenter,
                offset: Offset(0, overlayGapToMainButton),
                child: SizedBox(
                  width: clusterWidth,
                  height: clusterHeight,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Transform.translate(
                        offset: Offset(-outerDx, -lowDy + outerExtraDownDy),
                        child: _actionButton(
                          "먹이주기",
                          () =>
                              widget.onInteraction?.call(InteractionType.feed),
                          size: actionButtonSize,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-innerDx, -highDy),
                        child: _actionButton(
                          "놀아주기",
                          () =>
                              widget.onInteraction?.call(InteractionType.play),
                          size: actionButtonSize,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(innerDx, -highDy),
                        child: _actionButton(
                          "쓰다듬기",
                          () => widget.onInteraction?.call(InteractionType.pet),
                          size: actionButtonSize,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(outerDx, -lowDy + outerExtraDownDy),
                        child: _actionButton(
                          "혼자두기",
                          () =>
                              widget.onInteraction?.call(InteractionType.idle),
                          size: actionButtonSize,
                        ),
                      ),
                    ],
                  ),
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
    final mainButtonSize = 80.rClamp;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // 바텀
        SafeArea(
          child: Container(height: 70.hClamp, color: MainColors.mainLight),
        ),

        // 메인 버튼
        Positioned(
          bottom: 30.hClamp,
          child: GestureDetector(
            onTap: _toggleActions,
            child: CompositedTransformTarget(
              link: _actionLink,
              child: Container(
                width: mainButtonSize,
                height: mainButtonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MainColors.main,
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets,
                    color: MainColors.mainLight,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String text, VoidCallback onTap, {double? size}) {
    final effectiveSize = size ?? 55.rClamp;
    return GestureDetector(
      onTap: () {
        onTap();
        _hideActions();
      },
      child: Container(
        width: effectiveSize,
        height: effectiveSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: MainColors.mainLight, width: 1.2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.spClamp, color: MainColors.mainDark),
          ),
        ),
      ),
    );
  }
}
