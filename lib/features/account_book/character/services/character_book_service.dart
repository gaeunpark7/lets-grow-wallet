import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/character_book_item_model.dart';

class CharacterBookService {
  final SupabaseClient _supabase;

  CharacterBookService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _defaultImageUrlForStage(List<dynamic> images, String stage) {
    for (final raw in images) {
      if (raw is! Map<String, dynamic>) continue;
      final s = raw['stage']?.toString();
      final isDefault = raw['is_default'] == true;
      if (s == stage && isDefault) {
        return raw['image_url']?.toString() ?? '';
      }
    }
    return '';
  }

  Future<List<CharacterBookItem>> fetchCharacterBookItems() async {
    final userId = _supabase.auth.currentUser?.id;

    final characterRows = await _supabase.from('characters').select('''
        id,
        name,
        description,
        price,
        character_images (
          stage,
          image_url,
          is_default
        )
      ''');

    final characters = List<Map<String, dynamic>>.from(characterRows);

    final ownedByCharacterId = <String, Map<String, dynamic>>{};
    if (userId != null) {
      final ownedRows = await _supabase
          .from('user_characters')
          .select('character_id, experience, created_at, is_active')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      for (final row in List<Map<String, dynamic>>.from(ownedRows)) {
        final cid = row['character_id']?.toString();
        if (cid == null || cid.isEmpty) continue;
        // 최신 1건만 보관
        ownedByCharacterId.putIfAbsent(cid, () => row);
      }
    }

    final items = characters
        .map((c) {
          final characterId = c['id']?.toString() ?? '';
          final images = (c['character_images'] as List<dynamic>?) ?? const [];

          final eggUrl = _defaultImageUrlForStage(images, 'egg');
          final childUrl = _defaultImageUrlForStage(images, 'child');
          final adultUrl = _defaultImageUrlForStage(images, 'adult');

          final ownedRow = ownedByCharacterId[characterId];
          final isOwned = ownedRow != null;
          final isActive = isOwned ? (ownedRow['is_active'] == true) : false;
          final experience = isOwned ? _parseInt(ownedRow['experience']) : 0;
          final acquiredAt = isOwned
              ? _parseDateTime(ownedRow['created_at'])
              : null;

          return CharacterBookItem(
            characterId: characterId,
            name: c['name']?.toString() ?? '',
            description: c['description']?.toString() ?? '',
            price: _parseInt(c['price']),
            isOwned: isOwned,
            isActive: isActive,
            acquiredAt: acquiredAt,
            experience: experience,
            eggImageUrl: eggUrl,
            childImageUrl: childUrl,
            adultImageUrl: adultUrl,
          );
        })
        .toList(growable: false);

    items.sort((a, b) {
      if (a.isOwned != b.isOwned) return a.isOwned ? -1 : 1;

      if (a.isOwned && b.isOwned) {
        final at = a.acquiredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.acquiredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at); // 최신 먼저
      }

      // 미획득: price 내림차순
      return b.price.compareTo(a.price);
    });

    return items;
  }
}
