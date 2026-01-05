import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_action_bottom_bar.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_page_level.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/not_character.dart';
import 'package:lets_grow_wallet/features/account_book/model/user_character_model.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_character_service.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:lets_grow_wallet/utils/character_level_progress.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  final _userCharacterService = UserCharacterService();
  UserCharacterModel? _activeCharacter;
  bool _isLoading = true;

  Emotion _currentEmotion = Emotion.basic;
  Timer? _emotionTimer;

  CharacterLevelProgress _levelProgress() {
    final character = _activeCharacter;
    return characterLevelProgress(
      stage: character?.stage ?? Stage.egg,
      experience: character?.experience ?? 0,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadActiveCharacter();
  }

  Future<void> _precacheActiveCharacterImages(
    UserCharacterModel character,
  ) async {
    final urls = <String>{};

    for (final emotion in Emotion.values) {
      final url = character.imageUrlForEmotion(emotion);
      if (url.isNotEmpty) urls.add(url);
    }

    if (character.characterImage.isNotEmpty) {
      urls.add(character.characterImage);
    }

    for (final url in urls) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (_) {
        // ignore precache failures; Image.network will still handle errors
      }
    }
  }

  @override
  void dispose() {
    _emotionTimer?.cancel();
    super.dispose();
  }

  // 활성화된 캐릭터 불러오기
  Future<void> _loadActiveCharacter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final character = await _userCharacterService.getActiveCharacter();
      if (mounted) {
        setState(() {
          _activeCharacter = character;
          _isLoading = false;
        });

        if (character != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _precacheActiveCharacterImages(character);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('캐릭터 정보를 불러올 수 없습니다: $e')));
      }
    }
  }

  // 상호작용에 따른 감정 변화
  void onInteraction(InteractionType type) {
    final emotion =
        _activeCharacter?.emotionForInteraction(type) ??
        resolveEmotion(interaction: type);

    _emotionTimer?.cancel();

    setState(() {
      _currentEmotion = emotion;
    });

    _emotionTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _currentEmotion = Emotion.basic;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelProgress = _levelProgress();
    final size = MediaQuery.of(context).size;
    final imageUrl =
        _activeCharacter?.imageUrlForEmotion(_currentEmotion) ?? '';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: MainColors.mainLight),
              )
            : _activeCharacter == null
            ? NotCharacter()
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CharacterPageLevel(
                        level: "Lv.${levelProgress.level}",
                        characterName: _activeCharacter!.characterName,
                        progress: levelProgress.progress,
                        currentExp: levelProgress.currentExp.toDouble(),
                        maxExp: levelProgress.maxExp.toDouble(),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        height: size.width * 1,
                        width: size.width * 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(120),
                          border: Border.all(color: Colors.black, width: 0.8),
                        ),
                        child: Center(
                          child: Image.network(
                            imageUrl,
                            width: size.width * 0.6,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  child,
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: MainColors.mainLight,
                                    ),
                                  ),
                                ],
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.pets,
                                size: 100,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              context.push('${Routes.character}/${Routes.characterDetail}'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: MainColors.mainLight,
          child: Icon(Icons.pets, color: Colors.white),
        ),
        bottomNavigationBar: CharacterActionBottomBar(
          onInteraction: onInteraction,
        ),
      ),
    );
  }
}
