import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_grow_wallet/features/user/model/user_profile_model.dart';
import 'package:lets_grow_wallet/features/user/services/user_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final isPremiumProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileNotifierProvider).valueOrNull;
  return profile?.isPremium ?? false;
});

final authUserIdProvider = StreamProvider<String?>((ref) async* {
  yield Supabase.instance.client.auth.currentUser?.id;
  await for (final event in Supabase.instance.client.auth.onAuthStateChange) {
    yield event.session?.user.id;
  }
});

final userProfileNotifierProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileModel?>(() {
      return UserProfileNotifier();
    });

class UserProfileNotifier extends AsyncNotifier<UserProfileModel?> {
  final _service = UserProfileService();

  @override
  Future<UserProfileModel?> build() async {
    // 로그인/로그아웃 시 자동 갱신
    ref.watch(authUserIdProvider);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;
    return _service.getUserProfile(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  Future<void> updateNickname(String newNickname) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final trimmed = newNickname.trim();
    if (trimmed.isEmpty) return;

    // 화면 즉시 반영(optimistic update)
    final previous = current;
    state = AsyncValue.data(current.copyWith(nickname: trimmed));

    try {
      await _service.updateNickname(current.id, trimmed);
    } catch (e, st) {
      // 실패 시 롤백
      state = AsyncValue.data(previous);
      Error.throwWithStackTrace(e, st);
    }
  }

  void setPremiumLocal({required DateTime purchasedAt}) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(isPremium: true, premiumPurchasedAt: purchasedAt),
    );
  }
}
