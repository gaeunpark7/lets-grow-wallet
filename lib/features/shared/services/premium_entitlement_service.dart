import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PremiumEntitlementService {
  PremiumEntitlementService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String krwangCharacterId =
      '2dacd2ae-bd33-4c84-81ba-4dd19516f2e4';

  static const _uuid = Uuid();
  Future<void> verifyAndGrantPremium({
    required String userId,
    required DateTime purchasedAt,
    String? productId,
    String? serverVerificationData,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'verify_and_grant_premium',
        body: {
          'user_id': userId,
          'purchased_at': purchasedAt.toIso8601String(),
          'product_id': productId,
          'purchase_token': serverVerificationData,
        },
      );

      if (response.status != 200) throw Exception('서버 검증 실패');
      debugPrint('프리미엄 및 캐릭터 지급 완료!');
    } catch (e) {
      debugPrint('오류: $e');
      rethrow;
    }
  }

  Future<void> _grantCharacterIfNeeded({
    required String userId,
    required String characterId,
  }) async {
    final existing = await _supabase
        .from('user_characters')
        .select('id')
        .eq('user_id', userId)
        .eq('character_id', characterId)
        .limit(1)
        .maybeSingle();

    if (existing != null) return;

    await _supabase.from('user_characters').insert({
      'id': _uuid.v4(),
      'user_id': userId,
      'character_id': characterId,
      'experience': 0,
      'is_active': false,
      'stage': 'egg',
    });
  }
}
