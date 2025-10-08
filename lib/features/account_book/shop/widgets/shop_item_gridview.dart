import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/shop/model/shop_item.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ShopItemGridview extends StatefulWidget {
  final Function(Map<String, dynamic>) onItemSelected;

  const ShopItemGridview({super.key, required this.onItemSelected});
  @override
  State<ShopItemGridview> createState() => _ShopItemGridviewState();
}

class _ShopItemGridviewState extends State<ShopItemGridview> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Expanded(
      flex: 6,
      child: Container(
        width: mediaQuery.size.width * 1,
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
        ),

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10, // 아이템 간의 가로 간격
              mainAxisSpacing: 10, // 아이템 간의 세로 간격
              childAspectRatio: 0.6, // 아이템의 가로/세로 비율 설정
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index]; // 현재 아이템 가져오기
              return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.onItemSelected({
                      "itemImage": item.image,
                      "itemName": item.name,
                      "itemPrice": item.price,
                      "itemDesc": item.description,
                    });
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: mediaQuery.size.height * 0.16,
                      width: mediaQuery.size.width * 0.25,
                      decoration: BoxDecoration(
                        border: Border.all(color: MainColors.mainLight),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "이미지 ${index + 1}",
                          style: TextStyle(
                            fontSize: 16,
                            color: MainColors.mainLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: MainColors.mainDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 12),
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
