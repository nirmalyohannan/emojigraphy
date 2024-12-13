import 'dart:math';
import 'dart:ui';

double getColorDistance(Color color1, Color color2) {
  double distance = sqrt(pow((color1.red - color2.red), 2) +
      pow((color1.green - color2.green), 2) +
      pow((color1.blue - color2.blue), 2));
  return distance.abs();
}
