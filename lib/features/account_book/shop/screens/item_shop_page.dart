import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/shop_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/character_service.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_buy_button.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_detail.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_gridview.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class ItemShopPage extends ConsumerWidget {
  const ItemShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(characterShopNotifierProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const ShopAppbar(),
          iconTheme: IconThemeData(color: MainColors.mainDark),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: shopAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(color: MainColors.mainLight),
            ),
            error: (e, st) => Center(child: Text('오류: $e')),
            data: (shop) {
              final items = shop.items;
              final CharacterModel? selectedItem = shop.selectedItem;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShopItemGridview(
                    items: items,
                    onItemSelected: (item) {
                      ref
                          .read(characterShopNotifierProvider.notifier)
                          .selectItem(item);
                    },
                  ),

                  SizedBox(height: 12),
                  selectedItem == null
                      ? const Center(child: CircularProgressIndicator())
                      : ShopItemDetail(item: selectedItem),

                  SizedBox(height: 12),
                  ShopItemBuyButton(
                    isPurchased: selectedItem?.isPurchased ?? false,
                    onPressed: shop.isPurchasing
                        ? null
                        : () async {
                            try {
                              await ref
                                  .read(characterShopNotifierProvider.notifier)
                                  .purchaseSelected();
                            } on InsufficientCoinException {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(content: Text('코인이 부족합니다.')),
                                );
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(content: Text('구매에 실패했습니다: $e')),
                                );
                            }
                          },
                  ),
                  SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
