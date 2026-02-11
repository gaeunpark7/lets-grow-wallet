import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/app/scaffold_messenger_key.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/shop_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/admob_service.dart';
import 'package:lets_grow_wallet/features/account_book/services/character_service.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_buy_button.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_detail.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_item_gridview.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ItemShopPage extends ConsumerStatefulWidget {
  const ItemShopPage({super.key});

  @override
  ConsumerState<ItemShopPage> createState() => _ItemShopPageState();
}

class _ItemShopPageState extends ConsumerState<ItemShopPage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
  }

  void _createBannerAd() {
    final adUnitId = AdmobService.BannerAdUnitId;
    if (adUnitId == null) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: AdmobService.bannerAdListener,
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.symmetric(horizontal: 24.wClamp),
          child: shopAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(color: MainColors.mainLight),
            ),
            error: (e, st) {
              final error = FriendlyErrorMessage.resolve(e);
              return Center(child: Text(error.message));
            },
            data: (shop) {
              final items = shop.items;
              final CharacterModel? selectedItem = shop.selectedItem;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ShopItemGridview(
                    items: items,
                    onItemSelected: (item) {
                      ref
                          .read(characterShopNotifierProvider.notifier)
                          .selectItem(item);
                    },
                  ),
                  SizedBox(height: 12.hClamp),
                  selectedItem == null
                      ? const Center(child: CircularProgressIndicator())
                      : ShopItemDetail(item: selectedItem),

                  SizedBox(height: 12.hClamp),
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
                              showAppSnackBar('코인이 부족합니다.');
                            } catch (e) {
                              showAppSnackBar('구매에 실패하였습니다.');
                              print('아이템 구매 실패: $e');
                            }
                          },
                  ),
                  SizedBox(height: 12.hClamp),
                ],
              );
            },
          ),
        ),
        // 구매 버튼 하단 광고
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            height: 60.hClamp,
            alignment: Alignment.center,
            child: _bannerAd != null
                ? AdWidget(ad: _bannerAd!)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
