enum Stage { egg, child, adult }

enum InteractionType { idle, pet, feed, play }

enum Emotion { basic, happy, good, surprised, sad, angry }

Emotion resolveEmotion({required InteractionType interaction}) {
  switch (interaction) {
    case InteractionType.pet:
      return Emotion.happy;
    case InteractionType.feed:
      return Emotion.good;
    case InteractionType.play:
      return Emotion.surprised;
    case InteractionType.idle:
      return Emotion.basic;
  }
}
