import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:emojigraphy/helper/color_services/color_distance.dart';
import 'package:image/image.dart' as img;

class ColorEmoji {
  ColorEmoji({required this.color, required this.emojiImageMap}) {
    assert(emojiImageMap.isNotEmpty); //Should have atleast one entry
  }

  final Color color;
  Map<String, Uint8List> emojiImageMap;
  img.Image? _emojiAsImage;
  bool decodeImageAttempted = false;
  img.Image? get emojiImage {
    if (decodeImageAttempted) {
      //means either image is already decoded or decodeFailed
      //so doesnt need to decodeAgain
      return _emojiAsImage;
    }
    decodeImageAttempted = true;
    _emojiAsImage = img.decodeImage(emojiImageMap.values.first);
    return _emojiAsImage;
  }

  List<String> get emojis => emojiImageMap.keys.toList();
  List<Uint8List> get images => emojiImageMap.values.toList();
  int get r => color.red;
  int get g => color.green;
  int get b => color.blue;

  factory ColorEmoji.fromColorMapEntry(MapEntry<String, dynamic> entry) {
    List<String> colorRGB = entry.key.split(",");
    int r = int.parse(colorRGB[0]);
    int g = int.parse(colorRGB[1]);
    int b = int.parse(colorRGB[2]);
    Color color = Color.fromARGB(255, r, g, b);
    Map<String, Uint8List> decodedEmojiImageMap = (entry.value as Map).map(
        (key, value) => MapEntry<String, Uint8List>(key, base64Decode(value)));
    return ColorEmoji(emojiImageMap: decodedEmojiImageMap, color: color);
  }

  MapEntry<String, dynamic> toColorMapEntry() {
    String colorString = "${color.red},${color.green},${color.blue}";
    return MapEntry<String, dynamic>(
        colorString,
        emojiImageMap.map((key, value) => MapEntry(
            key,
            base64Encode(
                value)))); //need to convert Uint8List to base64. Otherwise JsonEncode wont work
  }

  void addEmoji(String emoji, Uint8List image) {
    emojiImageMap[emoji] = image;
  }

  double calcColorDistance(Color other) {
    return getColorDistance(color, other);
  }
}
