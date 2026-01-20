import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class FloatingMenuButton extends StatefulWidget {
  const FloatingMenuButton({super.key});

  @override
  State<FloatingMenuButton> createState() => _FloatingMenuButtonState();
}

class _FloatingMenuButtonState extends State<FloatingMenuButton> {
  bool _isFabExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // FAB 1
          if (_isFabExpanded)
            Positioned(
              right: 65,
              bottom: 5,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                heroTag: "fab1",
                mini: true,
                backgroundColor: MainColors.mainLight,
                onPressed: () => context.push(Routes.character),
                child: const Icon(Icons.pets, color: Colors.white),
              ),
            ),

          // FAB 2
          if (_isFabExpanded)
            Positioned(
              right: 50,
              bottom: 55,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                heroTag: "fab2",
                mini: true,
                backgroundColor: MainColors.mainLight,
                onPressed: () => context.push(Routes.quest),
                child: const Icon(Icons.star, color: Colors.white),
              ),
            ),

          // FAB 3
          if (_isFabExpanded)
            Positioned(
              right: 0,
              bottom: 65,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                heroTag: "fab3",
                mini: true,
                backgroundColor: MainColors.mainLight,
                onPressed: () => context.push(Routes.shop),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
            ),

          // Main FAB
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isFabExpanded = !_isFabExpanded;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: MainColors.mainLight,
              child: AnimatedRotation(
                turns: _isFabExpanded ? 0.130 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isFabExpanded ? Icons.add : Icons.cruelty_free_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
