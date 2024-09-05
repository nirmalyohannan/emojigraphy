import 'dart:developer';
import 'dart:ui' as ui;

import 'package:emojigraphy/helper/find_closest_color.dart';
import 'package:emojigraphy/model/color_emoji.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

///[message] should Contain
///'image' as Image,
///'colorMap' as Map<Color,ColorEmoji>
///'rootIsolateToken' as IsolateToken
List<List<ColorEmoji>> imageToEmoji(Map<String, dynamic> message) {
  img.Image image = message['image'];

  Map<Color, ColorEmoji> colorMap =
      message['colorMap'] as Map<Color, ColorEmoji>;
  //+++++FOR ISOLATE+++++++++++++++++++
  RootIsolateToken rootIsolateToken =
      message['rootIsolateToken'] as RootIsolateToken;
  ui.DartPluginRegistrant.ensureInitialized();
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  //+++++++++++++++++++++++++++++++++++

  List<Color> availableColors = colorMap.keys.toList();
  List<List<ColorEmoji>> emojiPicture = [];
  for (int y = 0; y < image.height; y++) {
    emojiPicture.add([]);
    for (int x = 0; x < image.width; x++) {
      img.Pixel pixel = image.getPixel(x, y);
      Color pixelColor = Color.fromARGB(
          pixel.a.toInt(), pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
      Color closestColor = findClosestColor(pixelColor, availableColors);
      ColorEmoji emoji = colorMap[closestColor]!;
      emojiPicture[y].add(emoji);
    }
    log("Completed Row ${y + 1}/${image.height}");
  }

  return emojiPicture;
}
