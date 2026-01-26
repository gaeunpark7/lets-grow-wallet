import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
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

    //상점 목록>이미지 로드에서 제외
    const excludedNames = {'크왕', '꽃개'};
    final filteredItems = items
        .where((item) => !excludedNames.contains(item.name.trim()))
        .toList();

    return Expanded(
      flex: 6,
      child: Container(
        width: mediaQuery.size.width,
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          //그리드 뷰
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final opacity = item.isPurchased ? 1.0 : 0.30;

              return GestureDetector(
                onTap: () => onItemSelected(item),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //아이템 컨테이너(테두리)
                    Container(
                      height: mediaQuery.size.height * 0.16,
                      width: mediaQuery.size.width * 0.25,
                      decoration: BoxDecoration(
                        border: Border.all(color: MainColors.mainLight),
                      ),
                      //아이템 이미지
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Opacity(
                          opacity: opacity,
                          child: item.image.isNotEmpty
                              ? Center(
                                  child: Image.network(
                                    item.image,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: MainColors.mainLight,
                                        ),
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
                                    style: TextStyle(
                                      color: MainColors.mainLight,
                                    ),
                                  ),
                                ),
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
