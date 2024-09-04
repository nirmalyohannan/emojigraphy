import 'package:emojigraphy/helper/color_distance.dart';
import 'package:flutter/material.dart';

Color findClosestColor(Color srcColor, List<Color> colorList) {
  Color closestColor = colorList[0];
  double currentClosestDistance = getColorDistance(srcColor, colorList[0]);
  for (Color color in colorList) {
    double distance = getColorDistance(srcColor, color);
    if (distance < currentClosestDistance) {
      closestColor = color;
      currentClosestDistance = distance;
    }
  }
  return closestColor;
}
