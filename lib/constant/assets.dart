class Assets {
  static const emojiSets = _EmojiSets();
  static const images = _Images();
}

class _EmojiSets {
  final String set1 = "assets/Color Data/emoji_set_1.json";
  final String set1Emojisfolder = "assets/Color Data/emoji_set_1";
  List<String> get getAllSets => [set1];

  const _EmojiSets();
}

class _Images {
  final String homeScreenBG = "assets/images/home_screen_bg.jpeg";
  final String sample1Input = "assets/images/sample1_input.jpeg";
  final String sample1Output = "assets/images/sample1_output.jpeg";

  const _Images();
}
