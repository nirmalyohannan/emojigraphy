import 'dart:ui';

import 'package:emojigraphy/helper/color_distance.dart';

class ColorEmoji {
  ColorEmoji({required this.emojis, required this.color});

  List<String> emojis;
  Color color;

  int get r => color.red;
  int get g => color.green;
  int get b => color.blue;

  factory ColorEmoji.fromColorMapEntry(MapEntry<String, dynamic> entry) {
    String key = entry.key;
    List<String> colorRGB = key.split(",");
    int r = int.parse(colorRGB[0]);
    int g = int.parse(colorRGB[1]);
    int b = int.parse(colorRGB[2]);
    Color color = Color.fromARGB(255, r, g, b);
    List<String> emojis = (entry.value as List).cast<String>();
    return ColorEmoji(emojis: emojis, color: color);
  }

  double calcColorDistance(Color other) {
    return getColorDistance(color, other);
  }
}
