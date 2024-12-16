import 'dart:developer';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:emojigraphy/helper/image_services/fill_image.dart';
import 'package:emojigraphy/helper/color_services/find_closest_color.dart';
import 'package:emojigraphy/model/color_emoji.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

///[message] should Contain
///'image' as Image,
///'colorMap' as Map<Color,ColorEmoji>
///'rootIsolateToken' as IsolateToken
img.Image genereteEmojiPicture(Map<String, dynamic> message) {
  img.Image inputImage = message['image'];

  Map<Color, ColorEmoji> colorMap =
      message['colorMap'] as Map<Color, ColorEmoji>;
  //+++++FOR ISOLATE+++++++++++++++++++
  RootIsolateToken rootIsolateToken =
      message['rootIsolateToken'] as RootIsolateToken;
  ui.DartPluginRegistrant.ensureInitialized();
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  SendPort sendPort = message['sendPort'] as SendPort;
  //+++++++++++++++++++++++++++++++++++
  List<Color> availableColors = colorMap.keys.toList();
  int emojiWidth = 100; //Each Emoji has 100 Pixel Width in ColorEmoji
  int emojiHeight = 100;

  int outputImageWidth = inputImage.width *
      emojiWidth; //Input image's each pixel will be represented with 100x100 emoji
  int outputImageHeight = inputImage.height * emojiHeight;

  img.Image outputImage =
      img.Image(width: outputImageWidth, height: outputImageHeight);
  log("Starting Generate Emoji Loop", name: "generateEmojiPicture");
  for (int y = 0; y < inputImage.height; y++) {
    for (int x = 0; x < inputImage.width; x++) {
      //Get color of current pixel
      img.Pixel pixel = inputImage.getPixel(x, y);
      Color pixelColor = Color.fromARGB(
          pixel.a.toInt(), pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
      //Find closest color to current pixel from available colors
      Color closestColor = findClosestColor(pixelColor, availableColors);
      //Get emoji corresponding to closest color
      ColorEmoji emoji = colorMap[closestColor]!;
      //Fill emoji in output Image at (x,y) position
      if (emoji.emojiImage == null) continue;
      //Fill output image's area starting from (x,y) with emoji
      outputImage = fillImage(outputImage,
          startX: x * 100, startY: y * 100, fillWith: emoji.emojiImage!);
    }
    double progess = (y / inputImage.height);
    if (kDebugMode) {
      double progressPerc = progess * 100;
      log(
        "Completed ${progressPerc.toStringAsFixed(2)}%",
        name: "generateEmojiPicture",
      );
    }
    //Send Progress through Binary Messenger
    sendPort.send(progess);
  }
  log("Emoji Image Generated", name: "generateEmojiPicture");
  log("Compressing Emoji Image by 50%", name: "generateEmojiPicture");
  outputImage = img.copyResize(outputImage,
      width: outputImageWidth ~/ 2, height: outputImageHeight ~/ 2);
  return outputImage;
}
