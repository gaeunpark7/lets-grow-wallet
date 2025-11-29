import 'package:flutter/material.dart';
// import 'package:lets_grow_wallet/features/account_book/character/model/character_model.dart';
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
  int seletedCharacterIndex = 0; // 선택된 캐릭터 인덱스

  // final List<Character> characters = [
  //   Character(name: "꽃개", level: 1, description: "꽃을 단 강아지", imageUrl: ""),
  //   Character(
  //     name: "멋쟁이 토마토",
  //     level: 2,
  //     description: "멋진 토마토 캐릭터",
  //     imageUrl: "",
  //   ),
  //   Character(name: "언덕", level: 3, description: "얼은 오리", imageUrl: ""),
  //   Character(
  //     name: "반햄",
  //     level: 4,
  //     description: "바나나를 좋아하는 햄스터",
  //     imageUrl: "assets/images/blaze.png",
  //   ),
  //   Character(
  //     name: "멍개",
  //     level: 5,
  //     description: "빙글빙글 도는 개",
  //     imageUrl: "assets/images/aqua.png",
  //   ),
  //   Character(
  //     name: "여보개",
  //     level: 6,
  //     description: "주부 9단",
  //     imageUrl: "assets/images/terra.png",
  //   ),
  // ];

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
                      Expanded(
                        child: CharacterBookList(
                          onCharacterSelected: (index) {
                            setState(() {
                              seletedCharacterIndex = index;
                            });
                          },
                        ),
                      ),
                      Text(
                        "달성률 25%",
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
              // CharacterBookListDetail(
              //   selectedCharacterIndex: seletedCharacterIndex,
              //   characters: characters,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
