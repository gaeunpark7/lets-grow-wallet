import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/character_service.dart';
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
  List<CharacterModel> characterItems = []; // 받아온 아이템 리스트
  CharacterModel? selectedItem; // 선택된 아이템

  final _characterService = CharacterService();

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final result = await _characterService.fetchCharacters();
    setState(() {
      characterItems = result;
      if (result.isNotEmpty) {
        selectedItem = result[0]; // 초기값 첫번째 아이템
      }
    });
  }

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
                items: characterItems,
                onItemSelected: (item) {
                  setState(() {
                    selectedItem = item;
                  });
                },
              ),

              SizedBox(height: 12),
              //아이템 상세보기
              selectedItem == null
                  ? Center(child: CircularProgressIndicator())
                  : ShopItemDetail(item: selectedItem!),

              SizedBox(height: 12),
              ShopItemBuyButton(),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
