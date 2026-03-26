import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 3.0,
      color: MainColors.mainLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽 아이콘 2개
          Row(
            children: [
              _BottomIcon(
                icon: Icons.home,
                index: 0,
                selectedIndex: selectedIndex,
                onTap: onTabSelected,
                iconSize: 42,
              ),
              _BottomIcon(
                icon: Icons.pie_chart,
                index: 1,
                selectedIndex: selectedIndex,
                onTap: onTabSelected,
                iconSize: 40,
              ),
            ],
          ),
          // 오른쪽 아이콘 2개
          Row(
            children: [
              _BottomIcon(
                icon: Icons.calendar_today,
                index: 2,
                selectedIndex: selectedIndex,
                onTap: onTabSelected,
                iconSize: 40,
              ),
              _BottomIcon(
                icon: Icons.account_circle,
                index: 3,
                selectedIndex: selectedIndex,
                onTap: onTabSelected,
                iconSize: 42,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;
  final double iconSize;

  const _BottomIcon({
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedIndex == index ? Colors.white : Colors.white60,
        size: iconSize,
      ),
      onPressed: () => onTap(index),
    );
  }
}
