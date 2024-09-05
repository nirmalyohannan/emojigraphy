import 'dart:developer';
import 'dart:io';
import 'package:emojigraphy/controller/color_data_controller.dart';
import 'package:emojigraphy/helper/image_to_emoji.dart';
import 'package:emojigraphy/model/color_emoji.dart';
import 'package:emojigraphy/views/emoji_extractor_screen/emoji_extractor_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? selectedImage;
  Uint8List? renderImage;
  List<List<ColorEmoji>> emojiPic = [];
  bool isProcessing = false;
  double progress = 0;
  double pixelPerSecond = 0;

  var transformationController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: selectedImage == null
              ? Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: double.infinity),
                    pickImageButton(),
                    extractorButton(),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedImage != null)
                      Expanded(
                        child: _ImageViewer(
                          selectedImage: selectedImage,
                          // controller: transformationController,
                        ),
                      ),
                    if (selectedImage != null)
                      Expanded(
                        child: renderImage != null
                            ? _ImageViewer(selectedImage: renderImage)
                            : EmojiPicViewer(
                                transformationController:
                                    transformationController,
                                emojiPic: emojiPic),
                      ),
                    if (isProcessing) buildProgressIndicator(),
                    if (isProcessing)
                      Text(
                          "Speed: ${pixelPerSecond.toStringAsFixed(2)} pixels/second"),
                    if (!isProcessing) pickImageButton(),
                    extractorButton(),
                    if (isProcessing)
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red),
                          onPressed: () {
                            setState(() {
                              isProcessing = false;
                            });
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text("Stop Processing")),
                  ],
                ),
        ),
      ),
    );
  }

  Widget extractorButton() {
    if (kDebugMode && !isProcessing) {
      return TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EmojiExtractorScreen()));
          },
          child: const Text("Extractor"));
    }
    return const SizedBox.shrink();
  }

  ElevatedButton pickImageButton() {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(color: Colors.black),
            )),
        onPressed: () async {
          var imageFile = await pickImage();
          if (imageFile != null) {
            selectedImage = await imageFile.readAsBytes();
            setState(() {});
          }
          //add a delay
          await Future.delayed(const Duration(seconds: 1));
          processImage();
        },
        icon: const Icon(Icons.image, color: Colors.black),
        label: const Text(
          "Pick Image",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ));
  }

  Row buildProgressIndicator() {
    return Row(
      children: [
        Flexible(
          child: Stack(
            children: [
              const Opacity(
                  opacity: 0.4, child: LinearProgressIndicator(value: null)),
              LinearProgressIndicator(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                value: progress,
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
        Text("${(progress * 100).toStringAsFixed(2)}%")
      ],
    );
  }

  Future<File?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowCompression: true,
        compressionQuality: 10);
    if (result != null) {
      return File(result.paths.first!);
    }
    return null;
  }

  void processImage() async {
    if (selectedImage == null) return;
    log("Starting to Process Image");
    //Image data to ui.Image object
    var image = img.decodeImage(selectedImage!);

    if (image == null || image.data == null) return;
    log("Original Image Dimensions: ${image.width}x${image.height}");
    image = img.copyResize(image, width: 150, maintainAspect: true);
    log("Compressed Image Dimensions: (${image.width}x${image.height})");
    setState(() {
      isProcessing = true;
    });
    var imageData = image.data!;
    log("Starting to PreFill Emoji List");
    // emojiPic = List.generate(image.height, (index) => []);
    var colorController = ColorDataController.instance;
    List<Color> availableColors = colorController.avaialableColors;
    Map<Color, ColorEmoji> usedColors = {};

    setState(() {});
    log("Starting to Loop Through image Pixels");

    // for loop through each pixels of the image
    int imageWidth = image.width;
    int imageHeight = image.height;
    DateTime previousRowCompleted = DateTime.now();
    emojiPic =
        await compute((message) => imageToEmoji(message), <String, dynamic>{
      'image': image,
      'colorMap': colorController.colorMap,
      'rootIsolateToken': RootIsolateToken.instance,
    });
    // for (var y = 0; y < imageHeight; y++) {
    //   //Set Row Width
    //   emojiPic[y] = [];
    //   for (var x = 0; x < imageWidth; x++) {
    //     if (isProcessing == false) return;
    //     var pixel = imageData.getPixel(x, y);
    //     var paintColor = pixel.clone();
    //     Color pixelColor = Color.fromARGB(paintColor.a.toInt(),
    //         paintColor.r.toInt(), paintColor.g.toInt(), paintColor.b.toInt());

    //     ColorEmoji colorEmoji;
    //     if (usedColors.containsKey(pixelColor)) {
    //       //if this color was used previously
    //       //No need to calculate closest color again
    //       //This reduces CPU usage
    //       colorEmoji = usedColors[pixelColor]!;
    //     } else {
    //       Color closestColor = findClosestColor(pixelColor, availableColors);
    //       colorEmoji = colorController.colorMap[closestColor]!;
    //     }
    //     usedColors[pixelColor] = colorEmoji;
    //     // log("Image Pixel: ($x, $y) ");
    //     emojiPic[y].add(colorEmoji);
    //     // Add a delay to reduce CPU usage
    //     await Future.delayed(const Duration(milliseconds: 2));
    //     // Update the UI
    //   }

    //   DateTime currentRowCompleted = DateTime.now();
    //   Duration rowDuration =
    //       currentRowCompleted.difference(previousRowCompleted);
    //   pixelPerSecond = imageWidth / rowDuration.inSeconds;
    //   progress = y / imageHeight;
    //   setState(() {});

    //   previousRowCompleted = currentRowCompleted;
    // }

    setState(() {
      isProcessing = false;
    });
    log("Finished Processing Image");
    log("Rendering as Image");
    final Widget widget = createWidgetFromEmojiPic();
    // renderImage = await createImageFromWidget(widget);
    if (!mounted) return;
    log('Image Rendered');
    setState(() {});
  }

  Widget createWidgetFromEmojiPic() {
    return Column(
        children: List.generate(emojiPic.length, (index) {
      List<ColorEmoji> row = emojiPic[index];
      return Row(
          children: List.generate(row.length, (index) {
        var emoji = row[index];
        return Text(
          emoji.emojis.first,
          style: TextStyle(
              // backgroundColor: Colors.black,
              backgroundColor: emoji.color.withOpacity(0.5),
              fontSize: 3,
              wordSpacing: 0,
              letterSpacing: 0),
        );
      }));
    }));
  }
}

class EmojiPicViewer extends StatelessWidget {
  const EmojiPicViewer({
    super.key,
    required this.transformationController,
    required this.emojiPic,
  });

  final TransformationController transformationController;
  final List<List<ColorEmoji>> emojiPic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: InteractiveViewer(
          constrained: false,
          maxScale: 10,
          minScale: 0.1,
          transformationController: transformationController,
          child: Column(
              children: List.generate(emojiPic.length, (index) {
            List<ColorEmoji> row = emojiPic[index];
            return Row(
                children: List.generate(row.length, (index) {
              var emoji = row[index];
              return Text(
                emoji.emojis.first,
                style: TextStyle(
                    // backgroundColor: Colors.black,
                    backgroundColor: emoji.color.withOpacity(0.5),
                    fontSize: 3,
                    wordSpacing: 0,
                    letterSpacing: 0),
              );
            }));
          })),
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final TransformationController? controller;
  const _ImageViewer({
    required this.selectedImage,
    this.controller,
  });

  final Uint8List? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: LayoutBuilder(builder: (context, constraints) {
          return InteractiveViewer(
            alignment: Alignment.center,
            transformationController: controller,
            constrained: false,
            child: Image.memory(
              selectedImage!,
              height: constraints.maxHeight,
              // width: size.width * 0.8,
              fit: BoxFit.fitHeight,
            ),
          );
        }),
      ),
    );
  }
}
