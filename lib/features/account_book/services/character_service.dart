import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/character_model.dart';
import 'package:uuid/uuid.dart';

class InsufficientCoinException implements Exception {
  final String message;
  const InsufficientCoinException([this.message = '코인이 부족합니다.']);

  @override
  String toString() => message;
}

class CharacterService {
  static const _uuid = Uuid();

  //상점 - 캐릭터 목록 조회
  Future<List<CharacterModel>> fetchCharacters() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('characters')
          .select('''
      id,
      name,
      description,
      price,
      is_available,
      character_images!inner (
        image_url,
        is_default
      )
    ''')
          .eq('character_images.stage', 'egg')
          .eq('character_images.is_default', true);
      final List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(response);
      return dataList.map((data) => CharacterModel.fromMap(data)).toList();
    } on PostgrestException catch (e) {
      print(" Postgres Error: ${e.message}");
      throw Exception("Postgres error: ${e.message}");
    } catch (e) {
      print(" Unknown Error: $e");
      throw Exception("Unknown error: $e");
    }
  }

  // 상점 - 캐릭터 목록 + 유저 구매 여부 반영 및 정렬
  Future<List<CharacterModel>> fetchCharactersWithPurchase() async {
    final supabase = Supabase.instance.client;

    final characters = await fetchCharacters();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      // 로그인 전이면 구매 여부 없음: 가격 오름차순
      final sorted = [...characters];
      sorted.sort((a, b) => a.price.compareTo(b.price));
      return sorted;
    }

    // 최신 구매 기준으로 내림차순
    final response = await supabase
        .from('user_characters')
        .select('character_id, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final purchaseRows = List<Map<String, dynamic>>.from(response);

    final purchaseRankByCharacterId = <String, int>{};
    for (var i = 0; i < purchaseRows.length; i++) {
      final cid = purchaseRows[i]['character_id']?.toString();
      if (cid == null || cid.isEmpty) continue;
      // 중복 구매가 있을 경우 가장 최신(앞쪽)만 유지
      purchaseRankByCharacterId.putIfAbsent(cid, () => i);
    }

    final merged = characters
        .map(
          (c) => c.copyWith(
            isPurchased: purchaseRankByCharacterId.containsKey(c.id),
            purchaseRank: purchaseRankByCharacterId[c.id],
          ),
        )
        .toList(growable: false);

    // 정렬 규칙:
    // 1) 구매한 캐릭터: 최신 구매(내림차순) => purchaseRank 오름차순
    // 2) 구매하지 않은 알: 가격 오름차순
    merged.sort((a, b) {
      if (a.isPurchased != b.isPurchased) {
        return a.isPurchased ? -1 : 1;
      }

      if (a.isPurchased && b.isPurchased) {
        final ar = a.purchaseRank ?? 1 << 30;
        final br = b.purchaseRank ?? 1 << 30;
        return ar.compareTo(br);
      }

      return a.price.compareTo(b.price);
    });

    return merged;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> purchaseCharacter(CharacterModel character) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 이미 구매했으면 아무 것도 하지 않음
    final existing = await supabase
        .from('user_characters')
        .select('id')
        .eq('user_id', userId)
        .eq('character_id', character.id)
        .limit(1)
        .maybeSingle();
    if (existing != null) return;

    // coin 확인
    final coinRow = await supabase
        .from('user')
        .select('coin')
        .eq('id', userId)
        .maybeSingle();
    final currentCoin = _parseInt(coinRow?['coin']);
    if (currentCoin < character.price) {
      throw const InsufficientCoinException();
    }

    final newCoin = currentCoin - character.price;

    // coin 차감 (경합 대비: 현재 coin 값이 그대로일 때만 업데이트 시도)
    var updated = await supabase
        .from('user')
        .update({'coin': newCoin})
        .eq('id', userId)
        .eq('coin', currentCoin)
        .select('coin')
        .maybeSingle();

    if (updated == null) {
      // 한번 더 재시도
      final retryRow = await supabase
          .from('user')
          .select('coin')
          .eq('id', userId)
          .maybeSingle();
      final retryCoin = _parseInt(retryRow?['coin']);
      if (retryCoin < character.price) {
        throw const InsufficientCoinException();
      }

      final retryNewCoin = retryCoin - character.price;
      updated = await supabase
          .from('user')
          .update({'coin': retryNewCoin})
          .eq('id', userId)
          .eq('coin', retryCoin)
          .select('coin')
          .maybeSingle();

      if (updated == null) {
        throw Exception('코인 차감에 실패했습니다.');
      }
    }

    final userCharacterId = _uuid.v4();
    var insertedUserCharacter = false;
    try {
      await supabase.from('user_characters').insert({
        'id': userCharacterId,
        'user_id': userId,
        'character_id': character.id,
        'experience': 0,
        'is_active': false,
        'stage': 'egg',
      });
      insertedUserCharacter = true;

      await supabase.from('coin_logs').insert({
        'user_id': userId,
        'amount': -character.price,
        'reason': '캐릭터 구매: ${character.name}',
      });
    } catch (e) {
      // 보상적 롤백(최선)
      try {
        if (insertedUserCharacter) {
          await supabase
              .from('user_characters')
              .delete()
              .eq('id', userCharacterId);
        }

        final latestCoinRow = await supabase
            .from('user')
            .select('coin')
            .eq('id', userId)
            .maybeSingle();
        final latestCoin = _parseInt(latestCoinRow?['coin']);
        await supabase
            .from('user')
            .update({'coin': latestCoin + character.price})
            .eq('id', userId);
      } catch (_) {
        // rollback 실패는 무시(원본 에러를 던짐)
      }

      rethrow;
    }
  }
}
