import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

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
    //상점 목록>이미지 로드에서 제외
    const excludedNames = {'크왕', '꽃개'};
    final filteredItems = items
        .where((item) => !excludedNames.contains(item.name.trim()))
        .toList();

    return Expanded(
      flex: 6,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12.wClamp,
            vertical: 12.hClamp,
          ),
          //그리드 뷰
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.wClamp,
              mainAxisSpacing: 10.hClamp,
              childAspectRatio: 0.58,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final opacity = item.isPurchased ? 1.0 : 0.30;

              return GestureDetector(
                onTap: () => onItemSelected(item),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageBoxHeight = constraints.maxHeight * 0.86;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //아이템 컨테이너(테두리)
                        Container(
                          height: imageBoxHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: MainColors.mainLight),
                          ),
                          //아이템 이미지
                          child: Padding(
                            padding: EdgeInsets.all(8.wClamp),
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
                                          debugPrint(
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
                                        '이미지 없음',
                                        style: TextStyle(
                                          color: MainColors.mainLight,
                                          fontSize: 12.spClamp,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.hClamp),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.spClamp,
                            color: MainColors.mainDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
