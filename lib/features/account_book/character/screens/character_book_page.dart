import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_book_list.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_book_list_detail.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_list.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_title.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterBookPage extends StatefulWidget {
  const CharacterBookPage({super.key});

  @override
  State<CharacterBookPage> createState() => _CharacterBookPageState();
}

class _CharacterBookPageState extends State<CharacterBookPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: ShopAppbar(), backgroundColor: Colors.white),
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            children: [
              QuestTitle(title: "도감"),
              SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColors.mainLight),
                  ),
                  child: Column(
                    children: [
                      Expanded(child: CharacterBookList()),

                      Text(
                        "달성률",
                        style: TextStyle(
                          fontSize: 16,
                          color: MainColors.mainDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              CharacterBookListDetail(),
            ],
          ),
        ),
      ),
    );
  }
}
