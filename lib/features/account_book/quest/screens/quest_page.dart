import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_list.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_title.dart';
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
            // top: 12,
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        QuestTitle(title: "일일 미션"),
                        const SizedBox(height: 6),
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
                            //얇은 테두리 별
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: MainColors.mainLight,
                                  size: 60,
                                ),
                                Icon(Icons.star, color: Colors.white, size: 52),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Column(
                          children: List.generate(
                            3,
                            (index) => QuestList(index: index),
                          ),
                        ),
                        QuestTitle(title: "월별 미션"),
                        SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 2,
                            itemBuilder: (ctx, index) =>
                                QuestList(index: index),
                          ),
                        ),
                      ],
                    ),
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
