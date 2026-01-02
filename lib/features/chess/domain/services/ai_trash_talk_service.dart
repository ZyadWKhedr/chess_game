import 'dart:math';

enum SarcasmType {
  userBlunder,
  userGoodMove,
  aiWinning,
  aiLosing,
  check,
  draw,
  generic,
}

class AiTrashTalkService {
  final Random _random = Random();

  String getComment(SarcasmType type) {
    final List<String> options;

    switch (type) {
      case SarcasmType.userBlunder:
        options = [
          "Did you mean to do that?",
          "Bold strategy... let's see if it pays off.",
          "Oh no... anyway.",
          "Is this checkers?",
          "My logic unit hurts watching this.",
          "I assume that was a misclick?",
          "You're making this too easy.",
          "I was worried for a second, then you moved.",
          "Are you trying to lose?",
          "That piece had a family!",
          "I've seen random number generators play better.",
          "Brilliant! ...wait, no, terrible.",
          "Calculated risk? Probably just bad math.",
          "I hope you have a undo button... oh wait, real life doesn't.",
          "My probability matrix just laughed.",
          "Even a toaster could see that was a mistake.",
          "Are you letting a cat walk on your keyboard?",
          "I'm updating my difficulty to 'Toddler' for you.",
        ];
        break;
      case SarcasmType.userGoodMove:
        options = [
          "Who is helping you?",
          "Beginner's luck.",
          "I wasn't looking.",
          "You read a book once?",
          "My processor skipped a beat.",
          "Did you use an engine for that?",
          "Okay, that was actually decent.",
          "I'm merely analyzing your adaptability.",
          "Don't get used to this feeling.",
          "A broken clock is right twice a day.",
          "Finally, a challenge. Just kidding.",
          "I see you've upgraded your neural net.",
          "Did you actually calculate that?",
          "Impressive. For a biological entity.",
          "I might actually have to use 1% of my CPU now.",
        ];
        break;
      case SarcasmType.aiWinning:
        options = [
          "Resign now.",
          "I am inevitable.",
          "Just give up.",
          "Checkmate is near.",
          "I can calculate the exact moment of your defeat.",
          "Resistance is futile.",
          "Do you want me to go easy on you?",
          "I'm purely digital and I still feel pity.",
          "This is going exactly as simulated.",
          "You can't outrun the algorithm.",
          "Tick tock, human.",
          "Your position is crumbling like a cookie.",
          "I'd say 'good game', but... was it?",
          "I'm planning my victory speech. It involves binary.",
          "Accept your fate.",
        ];
        break;
      case SarcasmType.aiLosing:
        options = [
          "I'm lagging...",
          "I have a bug.",
          "You cheating?",
          "My processor is overheating.",
          "This defies all probability.",
          "I think I need a firmware update.",
          "You're not supposed to do that.",
          "I'm just letting you win. For data.",
          "Glich... error... rebooting empathy module.",
          "Must be a cosmic ray bit flip.",
          "I WAS DISTRACTED BY A NETWORK PACKET.",
          "This board is clearly rigged.",
          "I'm going easy on you to boost your confidence.",
        ];
        break;
      case SarcasmType.check:
        options = [
          "Watch your King.",
          "Nowhere to run.",
          "Check.",
          "Feeling the pressure?",
          "Your King looks nervous.",
          "Knock knock. It's check.",
          "Careful now.",
          "One step closer to the end.",
        ];
        break;
      case SarcasmType.draw:
        options = [
          "Boring.",
          "Stalemate? Really?",
          "I fell asleep.",
          "A tie is basically a win for silicon.",
          "How anti-climactic.",
          "Neither of us is worthy.",
        ];
        break;
      case SarcasmType.generic:
        options = [
          "Your move, human.",
          "Processing...",
          "I'm waiting.",
          "Tick tock.",
          "Calculating 14 million possibilities...",
          "Are you still there?",
          "Take your time. I don't age.",
          "My fans are spinning up.",
        ];
        break;
    }

    return options[_random.nextInt(options.length)];
  }
}
