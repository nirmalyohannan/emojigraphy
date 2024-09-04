import 'dart:convert';

import 'package:emojigraphy/constant/assets.dart';
import 'package:emojigraphy/model/color_emoji.dart';
import 'package:emojigraphy/model/task_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorDataController extends ChangeNotifier {
  //private static instance
  static ColorDataController instance = ColorDataController._();
  ColorDataController._();

  List<ColorEmoji> colorEmojis = [];
  Map<Color, ColorEmoji> colorMap = {};
  List<Color> avaialableColors = [];

  TaskStatus statusLoadColorData = TaskStatus.idle;
  Future<void> loadColorData() async {
    if (statusLoadColorData == TaskStatus.inProgress) return;
    statusLoadColorData = TaskStatus.inProgress;
    notifyListeners();
    colorEmojis.clear();
    colorMap.clear();
    avaialableColors.clear();
    //load color data
    //Load file from assets
    String rawString = await rootBundle.loadString(Assets.emojiSets.set1);

    Map<String, dynamic> json = jsonDecode(rawString) as Map<String, dynamic>;
    for (var entry in json.entries) {
      var colorEmoji = ColorEmoji.fromColorMapEntry(entry);
      colorEmojis.add(colorEmoji);
      colorMap[colorEmoji.color] = colorEmoji;
      avaialableColors.add(colorEmoji.color);
    }
    statusLoadColorData = TaskStatus.success;
    notifyListeners();
  }
}
