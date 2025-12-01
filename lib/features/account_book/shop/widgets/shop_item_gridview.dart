import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/features/account_book/shop/model/shop_item.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ShopItemGridview extends StatelessWidget {
  final Function(CharacterModel) onItemSelected;
  final List<CharacterModel> items;

  const ShopItemGridview({
    super.key,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Expanded(
      flex: 6,
      child: Container(
        width: mediaQuery.size.width,
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return GestureDetector(
                onTap: () => onItemSelected(item),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: mediaQuery.size.height * 0.16,
                      width: mediaQuery.size.width * 0.25,
                      decoration: BoxDecoration(
                        border: Border.all(color: MainColors.mainLight),
                      ),
                      child: item.image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.image,
                                fit: BoxFit.contain,
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (ctx, err, st) {
                                  print(
                                    'Image.network error for ${item.name}: $err\n$st',
                                  );

                                  return const Center(
                                    child: Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                "이미지 없음",
                                style: TextStyle(color: MainColors.mainLight),
                              ),
                            ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: MainColors.mainDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
