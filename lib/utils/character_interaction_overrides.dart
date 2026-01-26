import 'package:lets_grow_wallet/utils/character_interation_enum.dart';

typedef InteractionEmotionOverrides =
    Map<String, Map<Stage, Map<InteractionType, Emotion>>>;

/// 캐릭터별, 성장단계별 상호작용 감정 오버라이드.
const InteractionEmotionOverrides interactionEmotionOverridesByStage = {
  //꽃개
  '589c96d4-64cc-419c-8125-1e27dfb0d44b': {
    // egg: idle/pet -> surprised, feed/play -> happy
    Stage.egg: {
      InteractionType.idle: Emotion.surprised,
      InteractionType.pet: Emotion.surprised,
      InteractionType.feed: Emotion.happy,
      InteractionType.play: Emotion.happy,
    },
    // child/adult: feed->good, play->happy, pet->surprised, idle->sad
    Stage.child: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.happy,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.sad,
    },
    Stage.adult: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.happy,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.sad,
    },
  },

  //반햄
  'd2f425ca-c320-4c09-9b5a-ac2c265f2fda': {
    Stage.egg: {
      InteractionType.feed: Emotion.happy,
      InteractionType.play: Emotion.happy,
      InteractionType.pet: Emotion.sad,
      InteractionType.idle: Emotion.sad,
    },
    Stage.child: {
      InteractionType.feed: Emotion.happy,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.sad,
    },
    Stage.adult: {
      InteractionType.feed: Emotion.happy,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.sad,
    },
  },

  //언덕
  '02f47f9b-c1d5-4ce4-a129-b8c6a8c77ca4': {
    Stage.egg: {
      InteractionType.feed: Emotion.happy,
      InteractionType.play: Emotion.sad,
      InteractionType.pet: Emotion.happy,
      InteractionType.idle: Emotion.sad,
    },
    Stage.child: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.surprised,
      InteractionType.pet: Emotion.happy,
      InteractionType.idle: Emotion.sad,
    },
    Stage.adult: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.surprised,
      InteractionType.pet: Emotion.happy,
      InteractionType.idle: Emotion.sad,
    },
  },

  //멍개
  '5b0190bc-0aad-4594-9192-5f5bef7289c4': {
    Stage.child: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.surprised,
      InteractionType.pet: Emotion.angry,
      InteractionType.idle: Emotion.happy,
    },
    Stage.adult: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.surprised,
      InteractionType.pet: Emotion.angry,
      InteractionType.idle: Emotion.happy,
    },
  },

  //여보개
  'ff9403db-4238-480d-967e-7ab84fc3981d': {
    Stage.egg: {
      InteractionType.feed: Emotion.sad,
      InteractionType.play: Emotion.happy,
      InteractionType.pet: Emotion.happy,
      InteractionType.idle: Emotion.sad,
    },
    Stage.child: {
      InteractionType.feed: Emotion.sad,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.happy,
      InteractionType.idle: Emotion.angry,
    },
    Stage.adult: {
      InteractionType.feed: Emotion.sad,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.happy,
      InteractionType.idle: Emotion.angry,
    },
  },

  //멋쟁이토마토
  '86eab0a2-34b3-4f3b-813f-f7a9280dcb71': {
    Stage.egg: {
      InteractionType.feed: Emotion.sad,
      InteractionType.play: Emotion.happy,
      InteractionType.pet: Emotion.sad,
      InteractionType.idle: Emotion.happy,
    },
    Stage.child: {
      InteractionType.feed: Emotion.angry,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.happy,
    },
    Stage.adult: {
      InteractionType.feed: Emotion.angry,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.angry,
    },
  },

  //크왕
  '2dacd2ae-bd33-4c84-81ba-4dd19516f2e4': {
    Stage.egg: {
      InteractionType.feed: Emotion.happy,
      InteractionType.play: Emotion.happy,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.sad,
    },
    Stage.child: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.sad,
    },
    Stage.adult: {
      InteractionType.feed: Emotion.good,
      InteractionType.play: Emotion.good,
      InteractionType.pet: Emotion.surprised,
      InteractionType.idle: Emotion.sad,
    },
  },
};
