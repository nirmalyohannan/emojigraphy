import 'dart:developer';
import 'dart:isolate';

import 'package:emojigraphy/controller/color_data_controller.dart';
import 'package:emojigraphy/helper/file_manager.dart';
import 'package:emojigraphy/helper/image_services/generateEmojiPicture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageProcessController extends ChangeNotifier {
  ImageProcessController._();
  static final ImageProcessController instance = ImageProcessController._();

  bool isProcessing = false;
  double? progress;
  double pixelPerSecond = 0;
  Uint8List? outputImage;
  Uint8List? inputImage;

  void processImage(Uint8List srcImage) async {
    log("Starting to Process Image");
    inputImage = srcImage;
    isProcessing = true;
    notifyListeners();
    //Image data to ui.Image object
    img.Image image = prepareImage(inputImage!, width: 150);

    var colorController = ColorDataController.instance;
    ReceivePort receivePort = ReceivePort();
    //Start listening to Isolate for Progress
    receivePort.listen((message) {
      if (message is double) {
        progress = message;
        notifyListeners();
      }
    });
    //Generate Emoji Picture in Isolate
    img.Image processedImage = await compute(
        (message) => genereteEmojiPicture(message), <String, dynamic>{
      'image': image,
      'colorMap': colorController.colorMap,
      'rootIsolateToken': RootIsolateToken.instance,
      'sendPort': receivePort.sendPort
    });

    log("Finished Processing Image");
    log("Encoding Image to Jpg");
    outputImage = await compute(
        (message) => img.encodeJpg(message, quality: 60), processedImage);
    log('Encoding Completed');
    isProcessing = false;
    notifyListeners();
  }

  img.Image prepareImage(Uint8List data, {int? width, int? height}) {
    img.Image image = img.decodeImage(data)!;
    image = img.copyResize(image,
        width: width, height: height, maintainAspect: true);
    log("Compressed Src Image Dimensions: (${image.width}x${image.height})");
    return image;
  }

  void saveToDownload() async {
    if (outputImage == null) return;
    FileManager fileManager = FileManager.instance;
    await fileManager.saveToDownload(outputImage!, "EmojiPicture", "jpg");
  }

  void cancelProcess() {
    //TODO:
  }

  void _reset() {
    isProcessing = false;
    progress = null;
    outputImage = null;
    inputImage = null;
    notifyListeners();
  }
}
