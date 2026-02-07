import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_book_list.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_book_list_detail.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/character_book_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/quest/widgets/quest_title.dart';
import 'package:lets_grow_wallet/features/account_book/shop/widgets/shop_appbar.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class CharacterBookPage extends ConsumerWidget {
  const CharacterBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(characterBookNotifierProvider);
    final error = FriendlyErrorMessage.resolve(e);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: ShopAppbar(),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: MainColors.mainDark),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            left: 24.wClamp,
            right: 24.wClamp,
            bottom: 24.hClamp,
          ),
          child: Column(
            children: [
              QuestTitle(title: "도감"),
              SizedBox(height: 12.hClamp),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.wClamp),
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColors.mainLight),
                  ),
                  child: asyncState.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: MainColors.mainLight,
                      ),
                    ),
                    error: (e, _) => Center(child: Text(error.message)),
                    data: (state) {
                      final items = state.items;
                      final selected = state.selectedItem;

                      return Column(
                        children: [
                          Expanded(
                            child: CharacterBookList(
                              items: items,
                              selectedCharacterId: selected?.characterId,
                              onCharacterSelected: ref
                                  .read(characterBookNotifierProvider.notifier)
                                  .selectItem,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final total = items.length;
                              final owned = items
                                  .where((e) => e.isOwned)
                                  .length;
                              final percent = total == 0
                                  ? 0
                                  : ((owned / total) * 100).round();
                              return Text(
                                "달성률 $percent%",
                                style: TextStyle(
                                  fontSize: 16.h,
                                  color: MainColors.mainDark,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              asyncState.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (state) {
                  final selected = state.selectedItem;
                  if (selected == null) return const SizedBox.shrink();

                  final canActivate =
                      selected.isOwned && !selected.isActive && !state.isSaving;
                  final isActive = selected.isActive;

                  final label = state.isSaving
                      ? '선택 중...'
                      : (isActive ? '선택중' : '선택');

                  final bgColor = canActivate
                      ? MainColors.mainLight
                      : MainColors.mainLight.withOpacity(0.5);

                  return Column(
                    children: [
                      CharacterBookListDetail(item: selected),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: canActivate
                            ? () => ref
                                  .read(characterBookNotifierProvider.notifier)
                                  .activateSelected()
                            : null,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: bgColor,
                            // borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: state.isSaving
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
