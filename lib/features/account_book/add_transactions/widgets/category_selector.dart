import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/category_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final int? selectedIndex;
  final Function(int) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        // mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // childAspectRatio: 0.85,
      ),
      itemBuilder: (context, idx) {
        final category = categories[idx];
        final isSelected = selectedIndex == idx;
        return GestureDetector(
          onTap: () => onCategorySelected(idx),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? MainColors.mainLight : MainColors.main,
                  border: Border.all(
                    color: isSelected ? MainColors.mainLight : MainColors.main,
                    width: 2,
                  ),
                ),
                child: Icon(
                  category.icon,
                  color: isSelected ? Colors.white : MainColors.mainLight,
                  size: 28,
                ),
              ),
              SizedBox(height: 6.hClamp),
              Text(
                category.label,
                style: TextStyle(
                  color: MainColors.mainDark,
                  // color: isSelected ? MainColors.mainDark : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
