import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/character_book_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/character_service.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/user/services/user_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CharacterShopState {
  final List<CharacterModel> items;
  final String? selectedCharacterId;
  final bool isPurchasing;

  const CharacterShopState({
    required this.items,
    required this.selectedCharacterId,
    required this.isPurchasing,
  });

  CharacterModel? get selectedItem {
    final id = selectedCharacterId;
    if (id == null) return items.isNotEmpty ? items.first : null;
    for (final item in items) {
      if (item.id == id) return item;
    }
    return items.isNotEmpty ? items.first : null;
  }

  CharacterShopState copyWith({
    List<CharacterModel>? items,
    String? selectedCharacterId,
    bool? isPurchasing,
  }) {
    return CharacterShopState(
      items: items ?? this.items,
      selectedCharacterId: selectedCharacterId ?? this.selectedCharacterId,
      isPurchasing: isPurchasing ?? this.isPurchasing,
    );
  }
}

final coinNotifierProvider = AsyncNotifierProvider<CoinNotifier, int>(() {
  return CoinNotifier();
});

class CoinNotifier extends AsyncNotifier<int> {
  final _service = UserProfileService();

  @override
  Future<int> build() async {
    // 로그인/로그아웃 시 자동 갱신
    ref.watch(authUserIdProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;
    return _service.getUserCoin(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}

final characterShopNotifierProvider =
    AsyncNotifierProvider<CharacterShopNotifier, CharacterShopState>(() {
      return CharacterShopNotifier();
    });

class CharacterShopNotifier extends AsyncNotifier<CharacterShopState> {
  final _service = CharacterService();

  // 상점 화면에서 제외할 캐릭터
  static const Set<String> _excludedNames = {'크왕', '꽃개'};

  @override
  Future<CharacterShopState> build() async {
    // 로그인/로그아웃 시 자동 갱신
    ref.watch(authUserIdProvider);

    final previous = state.valueOrNull;
    final items = await _service.fetchCharactersWithPurchase();
    final filteredItems = items
        .where((item) => !_excludedNames.contains(item.name.trim()))
        .toList();

    final preservedSelectedId = previous?.selectedCharacterId;

    final selectedId =
        preservedSelectedId != null &&
            filteredItems.any((it) => it.id == preservedSelectedId)
        ? preservedSelectedId
        : (filteredItems.isNotEmpty ? filteredItems.first.id : null);

    return CharacterShopState(
      items: filteredItems,
      selectedCharacterId: selectedId,
      isPurchasing: false,
    );
  }

  void selectItem(CharacterModel item) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (_excludedNames.contains(item.name.trim())) return;
    state = AsyncValue.data(current.copyWith(selectedCharacterId: item.id));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  Future<void> purchaseSelected() async {
    final current = state.valueOrNull;
    final selected = current?.selectedItem;
    if (current == null || selected == null) return;

    // 연타/중복 호출 방지
    if (current.isPurchasing) return;

    state = AsyncValue.data(current.copyWith(isPurchasing: true));
    try {
      await _service.purchaseCharacter(selected);
      await refresh();
      ref.invalidate(coinNotifierProvider);
      // 구매 후 도감에서도 바로 반영되도록 갱신
      ref.invalidate(characterBookNotifierProvider);
    } finally {
      final after = state.valueOrNull;
      if (after != null) {
        state = AsyncValue.data(after.copyWith(isPurchasing: false));
      }
    }
  }
}
