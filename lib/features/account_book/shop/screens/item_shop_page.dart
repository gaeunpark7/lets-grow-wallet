import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/shop/model/shop_item.dart';
import 'package:lets_grow_wallet/features/account_book/shop/screens/theme_shop_page.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_buy_button.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_detail.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_gridview.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_title_button.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ItemShopPage extends StatefulWidget {
  const ItemShopPage({super.key});

  @override
  State<ItemShopPage> createState() => _ItemShopPageState();
}

class _ItemShopPageState extends State<ItemShopPage> {
  Map<String, dynamic>? selectedItem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: ShopAppbar(),
          iconTheme: IconThemeData(color: MainColors.mainDark),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShopTitleButton(text: "상점", backColor: MainColors.mainLight),
                  SizedBox(width: 10),
                  ShopTitleButton(
                    text: "테마",
                    textColor: MainColors.mainDark,
                    backColor: MainColors.main,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => ThemeShopPage()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              //아이템 그리드뷰
              ShopItemGridview(
                onItemSelected: (item) {
                  setState(() {
                    selectedItem = item;
                  });
                },
              ),
              SizedBox(height: 12),
              //아이템 상세보기
              ShopItemDetail(
                image: selectedItem?["itemImage"] ?? "이미지",
                name: selectedItem?["itemName"] ?? items[0].name,
                price: selectedItem?["itemPrice"] ?? items[0].price,
                description: selectedItem?["itemDesc"] ?? items[0].description,
              ),
              SizedBox(height: 12),
              //구매 버튼
              ShopItemBuyButton(),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
