import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class ShopItemDetail extends StatelessWidget {
  final CharacterModel item;
  const ShopItemDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: MainColors.mainLight),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.wClamp),
          child: Row(
            children: [
              Container(
                height: 150.hClamp,
                width: 96.wClamp,
                decoration: BoxDecoration(
                  border: Border.all(color: MainColors.mainLight),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.wClamp),
                  child: Opacity(
                    opacity: item.isPurchased ? 1.0 : 0.30,
                    child: item.image.isNotEmpty
                        ? Image.network(item.image, fit: BoxFit.contain)
                        : Center(
                            child: Text(
                              "이미지 없음",
                              style: TextStyle(
                                color: MainColors.mainLight,
                                fontSize: 12.spClamp,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(width: 10.wClamp),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.spClamp,
                        fontWeight: FontWeight.bold,
                        color: MainColors.mainDark,
                      ),
                    ),
                    SizedBox(height: 6.hClamp),
                    Text(
                      "가격: ${item.price}",
                      style: TextStyle(
                        color: MainColors.mainDark,
                        fontSize: 14.spClamp,
                      ),
                    ),
                    SizedBox(height: 6.hClamp),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: MainColors.mainDark,
                        fontSize: 13.spClamp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
