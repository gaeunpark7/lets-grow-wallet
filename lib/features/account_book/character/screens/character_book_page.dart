import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_book_list.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_book_list_detail.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_title.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

import '../model/character_book_item_model.dart';
import '../services/character_book_service.dart';

class CharacterBookPage extends StatefulWidget {
  const CharacterBookPage({super.key});

  @override
  State<CharacterBookPage> createState() => _CharacterBookPageState();
}

class _CharacterBookPageState extends State<CharacterBookPage> {
  final _service = CharacterBookService();

  bool _isLoading = true;
  List<CharacterBookItem> _items = const [];
  CharacterBookItem? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final items = await _service.fetchCharacterBookItems();
    setState(() {
      _items = items;

      final selectedId = _selected?.characterId;
      if (selectedId != null) {
        _selected = items.cast<CharacterBookItem?>().firstWhere(
          (e) => e?.characterId == selectedId,
          orElse: () => items.isNotEmpty ? items.first : null,
        );
      } else {
        _selected = items.isNotEmpty ? items.first : null;
      }

      _isLoading = false;
    });
  }

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
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: MainColors.mainLight,
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: CharacterBookList(
                                items: _items,
                                selectedCharacterId: _selected?.characterId,
                                onCharacterSelected: (item) {
                                  setState(() {
                                    _selected = item;
                                  });
                                },
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final total = _items.length;
                                final owned = _items
                                    .where((e) => e.isOwned)
                                    .length;
                                final percent = total == 0
                                    ? 0
                                    : ((owned / total) * 100).round();
                                return Text(
                                  "달성률 $percent%",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: MainColors.mainDark,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 12),
              if (!_isLoading && _selected != null)
                CharacterBookListDetail(item: _selected!),
              SizedBox(height: 12),
              //선택 버튼
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: MainColors.mainLight,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Center(
                    child: Text(
                      "선택",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
