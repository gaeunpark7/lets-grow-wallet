import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/character_book_item_model.dart';
import 'package:lets_grow_wallet/features/account_book/character/services/character_book_service.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/active_character_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/user_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_character_service.dart';

class CharacterBookState {
  final List<CharacterBookItem> items;
  final String? selectedCharacterId;
  final bool isSaving;

  const CharacterBookState({
    required this.items,
    required this.selectedCharacterId,
    required this.isSaving,
  });

  CharacterBookItem? get selectedItem {
    final id = selectedCharacterId;
    if (id == null) return items.isNotEmpty ? items.first : null;
    for (final item in items) {
      if (item.characterId == id) return item;
    }
    return items.isNotEmpty ? items.first : null;
  }

  CharacterBookState copyWith({
    List<CharacterBookItem>? items,
    String? selectedCharacterId,
    bool? isSaving,
  }) {
    return CharacterBookState(
      items: items ?? this.items,
      selectedCharacterId: selectedCharacterId ?? this.selectedCharacterId,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class CharacterBookNotifier extends AsyncNotifier<CharacterBookState> {
  final _service = CharacterBookService();
  final _userCharacterService = UserCharacterService();

  @override
  Future<CharacterBookState> build() async {
    // 로그인/로그아웃/계정 변경 시 자동 갱신
    ref.watch(authUserIdProvider);

    final previous = state.valueOrNull;
    final items = await _service.fetchCharacterBookItems();

    final selectedId =
        previous?.selectedCharacterId ??
        (items.isNotEmpty ? items.first.characterId : null);

    return CharacterBookState(
      items: items,
      selectedCharacterId: selectedId,
      isSaving: false,
    );
  }

  void selectItem(CharacterBookItem item) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(selectedCharacterId: item.characterId),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  Future<void> activateSelected() async {
    final current = state.valueOrNull;
    final selected = current?.selectedItem;
    if (current == null || selected == null) return;

    if (!selected.isOwned) return;
    if (current.isSaving) return;

    state = AsyncValue.data(current.copyWith(isSaving: true));
    try {
      await _userCharacterService.setActiveCharacterByCharacterId(
        selected.characterId,
      );
      await refresh();
      ref.invalidate(activeCharacterNotifierProvider);
    } finally {
      final after = state.valueOrNull;
      if (after != null) {
        state = AsyncValue.data(after.copyWith(isSaving: false));
      }
    }
  }
}

final characterBookNotifierProvider =
    AsyncNotifierProvider<CharacterBookNotifier, CharacterBookState>(() {
      return CharacterBookNotifier();
    });
