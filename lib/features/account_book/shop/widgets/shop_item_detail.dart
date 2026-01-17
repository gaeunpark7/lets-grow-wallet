import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.16,
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                  border: Border.all(color: MainColors.mainLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Opacity(
                    opacity: item.isPurchased ? 1.0 : 0.30,
                    child: item.image.isNotEmpty
                        ? Image.network(item.image, fit: BoxFit.contain)
                        : Center(
                            child: Text(
                              "이미지 없음",
                              style: TextStyle(color: MainColors.mainLight),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MainColors.mainDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "가격: ${item.price}",
                    style: TextStyle(color: MainColors.mainDark),
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(color: MainColors.mainDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
