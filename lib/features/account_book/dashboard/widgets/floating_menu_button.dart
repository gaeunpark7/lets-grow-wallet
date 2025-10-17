import 'package:flutter/material.dart';
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
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // FAB 1
        if (_isFabExpanded)
          Transform.translate(
            offset: const Offset(-65, -5),
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              heroTag: "fab1",
              mini: true,
              backgroundColor: MainColors.mainLight,
              onPressed: () {},
              child: const Icon(Icons.pets, color: Colors.white),
            ),
          ),

        // FAB 2
        if (_isFabExpanded)
          Transform.translate(
            offset: const Offset(-50, -55),
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              heroTag: "fab2",
              mini: true,
              backgroundColor: MainColors.mainLight,
              onPressed: () {},
              child: const Icon(Icons.star, color: Colors.white),
            ),
          ),

        // FAB 3
        if (_isFabExpanded)
          Transform.translate(
            offset: const Offset(0, -65),
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              heroTag: "fab3",
              mini: true,
              backgroundColor: MainColors.mainLight,
              onPressed: () {},
              child: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
          ),

        // Main FAB
        FloatingActionButton(
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
            turns: _isFabExpanded ? 0.130 : 0, //125
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isFabExpanded ? Icons.add : Icons.cruelty_free_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}
