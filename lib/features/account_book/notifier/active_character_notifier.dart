import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/account_book/model/user_character_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_character_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _authUserIdProvider = StreamProvider<String?>((ref) async* {
  yield Supabase.instance.client.auth.currentUser?.id;
  await for (final event in Supabase.instance.client.auth.onAuthStateChange) {
    yield event.session?.user.id;
  }
});

final activeCharacterNotifierProvider =
    AsyncNotifierProvider<ActiveCharacterNotifier, UserCharacterModel?>(() {
      return ActiveCharacterNotifier();
    });

class ActiveCharacterNotifier extends AsyncNotifier<UserCharacterModel?> {
  final _service = UserCharacterService();

  @override
  Future<UserCharacterModel?> build() async {
    ref.watch(_authUserIdProvider);
    return _service.getActiveCharacter();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
