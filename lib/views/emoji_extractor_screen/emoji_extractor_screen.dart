import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:emojigraphy/helper/color_services/average_color.dart';
import 'package:emojigraphy/model/color_emoji.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class EmojiExtractorScreen extends StatefulWidget {
  const EmojiExtractorScreen({super.key});

  @override
  State<EmojiExtractorScreen> createState() => _EmojiExtractorScreenState();
}

class _EmojiExtractorScreenState extends State<EmojiExtractorScreen> {
  Map<Color, ColorEmoji> colorMap = {};
  Emoji? currentEmoji;
  int defaultStartIndex = 0; //for debug
  int currentEmojiIndex = 0;
  bool isExtracting = false;
  bool isExporting = false;
  var emojis = UnicodeEmojis.allEmojis;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("😎 Emoji Extractor")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (currentEmoji != null)
                EmojiColorExtractor(
                    emoji: currentEmoji!, onColorExtracted: onColorExtracted),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: isExtracting
                          ? () => setState(() {
                                isExtracting = false;
                                currentEmojiIndex = 0;
                                currentEmoji = null;
                              })
                          : () => extractEmojiColors(),
                      child: isExtracting
                          ? const Text("Stop")
                          : const Text("Start")),
                  if (!isExtracting && colorMap.isNotEmpty)
                    TextButton(
                        onPressed: isExporting ? null : export,
                        child: isExporting
                            ? const CircularProgressIndicator()
                            : const Text("Export"))
                ],
              ),
              if (isExtracting)
                Stack(
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                        // color: ,
                      ),
                    ),
                    LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      minHeight: 6,
                      value: currentEmojiIndex / emojis.length,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              Text("Available Colors: ${colorMap.length}"),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: colorMap.entries
                        .map((e) => Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: e.key, shape: BoxShape.circle),
                            ))
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onColorExtracted(Color? color, Uint8List? imageData) async {
    if (currentEmoji == null) return;
    if (color == null) {
      log("Color not found", name: "Emoji Color Extractor");
      setNextEmoji();

      return;
    }
    if (imageData == null) {
      log("Image not found", name: "Emoji Color Extractor");
      setNextEmoji();

      return;
    }
    if (colorMap[color] == null) {
      colorMap[color] = ColorEmoji(
          color: color, emojiImageMap: {currentEmoji!.emoji: imageData});
    } else {
      colorMap[color]!.addEmoji(currentEmoji!.emoji, imageData);
    }
    //Add Delay
    await Future.delayed(const Duration(milliseconds: 40));

    setNextEmoji();
  }

  void extractEmojiColors() async {
    isExtracting = true;
    currentEmojiIndex = defaultStartIndex;
    currentEmoji = emojis[currentEmojiIndex];
    colorMap = {};
    setState(() {});

    log("Total Emoji Count: ${emojis.length}");
  }

  void setNextEmoji() {
    if (isExtracting == false) return;
    currentEmojiIndex++;
    if (currentEmojiIndex >= emojis.length) {
      //End loop
      isExtracting = false;
      setState(() {});
      return;
    }
    currentEmoji = emojis[currentEmojiIndex];
    setState(() {});
  }

  void export() async {
    if (isExporting) return;
    isExporting = true;
    setState(() {});
    //permission check
    if (!await Permission.storage.request().isGranted) {
      log("Permission Denied", name: "Emoji Color Extractor");
      return;
    }
    Map<String, dynamic> exportMap = {};
    int count = 0;
    for (var entry in colorMap.values) {
      exportMap.addEntries([entry.toColorMapEntry()]);
      count++;
      log("Mapped: $count/${colorMap.length}", name: "Emoji Color Extractor");
    }

    try {
      //Get Downloads Path from Path Provider
      final Directory directory;
      if (Platform.isAndroid) {
        // Redirects it to download folder in android
        directory = Directory("/storage/emulated/0/Download");
      } else {
        //TODO: Add support for iOS
        //TODO: Add support for MacOS
        //TODO: Add support for Windows
        directory = await getApplicationDocumentsDirectory();
      }
      final path = directory.path;
      final file = File('$path/color_data.json');
      if (!file.existsSync()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(jsonEncode(exportMap));

      log("Color Map Exported Successfully|| FileSize: ${file.lengthSync()}",
          name: "Emoji Color Extractor");
      log("File Path: ${file.path}", name: "Emoji Color Extractor");
      log("Emoji Images Exported Successfully", name: "Emoji Color Extractor");

      isExporting = false;
      setState(() {});
    } catch (e) {
      log(e.toString(), name: "Emoji Color Extractor");
      isExporting = false;
      setState(() {});
    }
  }
}

Future<void> saveUint8ListToFile(Uint8List data, String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
  await file.writeAsBytes(data, flush: true);
}

class EmojiColorExtractor extends StatefulWidget {
  final Emoji emoji;

  final void Function(Color? color, Uint8List? imageData) onColorExtracted;
  const EmojiColorExtractor({
    super.key,
    required this.emoji,
    required this.onColorExtracted,
  });

  @override
  State<EmojiColorExtractor> createState() => _EmojiColorExtractorState();
}

class _EmojiColorExtractorState extends State<EmojiColorExtractor> {
  Color? averageColor;
  GlobalKey repaintKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    extractAverageEmojiColor();
  }

  void extractAverageEmojiColor() {
    return WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(milliseconds: 0));
      Uint8List? imageData;
      try {
        imageData = await getImageData();
        averageColor = getAverageImageColor(imageData!, downscaleFactor: 8);
      } catch (e) {
        log(e.toString(), name: "Emoji Color Extractor");
      }
      widget.onColorExtracted(averageColor, imageData);
      if (mounted) {
        averageColor = averageColor;
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (oldWidget.emoji != widget.emoji) {
      averageColor = null;
      extractAverageEmojiColor();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<Uint8List?> getImageData() async {
    var boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    Uint8List imageMemory = byteData.buffer.asUint8List();

    return imageMemory;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RepaintBoundary(
        key: repaintKey,
        child: SizedBox.square(
          dimension: 100,
          child: Text(
            widget.emoji.emoji,
            textAlign: TextAlign.center,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: const TextStyle(
                wordSpacing: -10,
                letterSpacing: -10,
                height: 1.2,
                fontSize: 88,
                backgroundColor: Colors.black),
          ),
        ),
      ),
      Text(widget.emoji.name),
      //Box to Display color

      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: averageColor, shape: BoxShape.circle),
      )
    ]);
  }
}
