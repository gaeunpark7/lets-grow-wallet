import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_list.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  double currentExp = 70;
  double maxExp = 100;
  int level = 3;

  @override
  Widget build(BuildContext context) {
    final progress = currentExp / maxExp;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, title: ShopAppbar()),
        body: Padding(
          padding: const EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 1,
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColors.mainLight),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: MainColors.mainLight,
                            size: 60,
                          ),
                          Icon(
                            Icons.star,
                            color: MainColors.mainLight,
                            size: 60,
                          ),
                          Icon(
                            Icons.star_outline,
                            color: MainColors.mainLight,
                            size: 60,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (ctx, index) => QuestList(index: index),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
