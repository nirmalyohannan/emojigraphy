class Assets {
  static const emojiSets = _EmojiSets();
}

class _EmojiSets {
  final String set1 = "assets/Color Data/emoji_set_1.json";
  List<String> get getAllSets => [set1];

  const _EmojiSets();
}
