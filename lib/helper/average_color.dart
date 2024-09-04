import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

Future<Color?> getAverageImageColor(Uint8List imageData,
    {double downscaleFactor = 1}) async {
  img.Image? image = img.decodeImage(imageData);
  if (image == null) {
    return null;
  }
  //resize image
  image = img.copyResize(image,
      width: image.width ~/ downscaleFactor,
      height: image.height ~/ downscaleFactor);
  double red = 0;
  double green = 0;
  double blue = 0;
  double count = 0;
  //log details
  // log("Image Dimension: ${image.width}x${image.height}",
  //     name: "getAverageImageColor");
  for (int x = 0; x < image.width; x++) {
    for (int y = 0; y < image.height; y++) {
      img.Pixel pixel = image.getPixel(x, y);
      //if pixel is not transparent
      if (pixel.a == 0) continue;
      red = red + pixel.r;
      green = green + pixel.g;
      blue = blue + pixel.b;
      count = count + 1;
      //add delay
    }
  }
  int rf = red ~/ count;
  int gf = green ~/ count;
  int bf = blue ~/ count;
  return Color.fromRGBO(rf, gf, bf, 1);
}
