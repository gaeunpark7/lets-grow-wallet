import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_grow_wallet/app/router/route_paths.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_action_bottom_bar.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_page_character.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/character_page_level.dart';
import 'package:lets_grow_wallet/features/account_book/character/widgets/not_character.dart';
import 'package:lets_grow_wallet/features/account_book/model/user_character_model.dart';
import 'package:lets_grow_wallet/features/account_book/notifier/active_character_notifier.dart';
import 'package:lets_grow_wallet/features/account_book/services/user_character_service.dart';
import 'package:lets_grow_wallet/utils/character_interation_enum.dart';
import 'package:lets_grow_wallet/utils/character_level_progress.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/utils/friendly_error_message.dart';
import 'package:lets_grow_wallet/utils/screenutil_clamp.dart';

class CharacterPage extends ConsumerStatefulWidget {
  const CharacterPage({super.key});

  @override
  ConsumerState<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends ConsumerState<CharacterPage> {
  final _userCharacterService = UserCharacterService();

  Emotion _currentEmotion = Emotion.basic;
  Timer? _emotionTimer;
  late final ProviderSubscription<AsyncValue<UserCharacterModel?>>
  _activeCharacterSubscription;

  @override
  void initState() {
    super.initState();

    _activeCharacterSubscription = ref
        .listenManual<AsyncValue<UserCharacterModel?>>(
          activeCharacterNotifierProvider,
          (previous, next) {
            final prevId = previous?.valueOrNull?.id;
            final nextCharacter = next.valueOrNull;
            final nextId = nextCharacter?.id;

            if (prevId != nextId) {
              _emotionTimer?.cancel();
              if (mounted) {
                setState(() {
                  _currentEmotion = Emotion.basic;
                });
              }

              if (nextCharacter != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _precacheActiveCharacterImages(nextCharacter);
                });
              }
            }
          },
        );
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

    if (character.characterBackground.isNotEmpty) {
      urls.add(character.characterBackground);
    }

    for (final url in urls) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _emotionTimer?.cancel();
    _activeCharacterSubscription.close();
    super.dispose();
  }

  // 상호작용에 따른 감정 변화
  void onInteraction(InteractionType type) {
    final activeCharacter = ref
        .read(activeCharacterNotifierProvider)
        .valueOrNull;
    final characterId = activeCharacter?.characterId;
    if (characterId != null) {
      _userCharacterService.recordInteractionOncePerDay(
        characterId: characterId,
        interactionType: type,
      );
    }

    final emotion =
        activeCharacter?.emotionForInteraction(type) ??
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
    final activeCharacterAsync = ref.watch(activeCharacterNotifierProvider);

    return activeCharacterAsync.when(
      loading: () => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(color: MainColors.mainLight),
          ),
        ),
      ),
      error: (e, _) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FriendlyErrorMessage.of(e),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MainColors.mainDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.hClamp),
                  FilledButton(
                    onPressed: () => ref
                        .read(activeCharacterNotifierProvider.notifier)
                        .refresh(),
                    style: FilledButton.styleFrom(
                      backgroundColor: MainColors.mainLight,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      data: (activeCharacter) {
        final levelProgress = characterLevelProgress(
          stage: activeCharacter?.stage ?? Stage.egg,
          experience: activeCharacter?.experience ?? 0,
        );
        final imageUrl =
            activeCharacter?.imageUrlForEmotion(_currentEmotion) ?? '';
        final backgroundUrl = activeCharacter?.characterBackground ?? '';

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: activeCharacter == null
                ? NotCharacter()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 40.hClamp),
                                  CharacterPageLevel(
                                    level: "Lv.${levelProgress.level}",
                                    characterName:
                                        activeCharacter.characterName,
                                    progress: levelProgress.progress,
                                    currentExp: levelProgress.currentExp
                                        .toDouble(),
                                    maxExp: levelProgress.maxExp.toDouble(),
                                  ),
                                  SizedBox(height: 60.hClamp),
                                  CharacterPageCharacter(
                                    imageUrl: imageUrl,
                                    backgroundUrl: backgroundUrl,
                                    characterName:
                                        activeCharacter.characterName,
                                    isEggStage:
                                        activeCharacter.stage == Stage.egg,
                                    isAdultStage:
                                        activeCharacter.stage == Stage.adult,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'character-detail-fab',
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
      },
    );
  }
}
