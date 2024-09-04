import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:emojigraphy/helper/average_color.dart';
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
  Map<Color, List<Emoji>> colorMap = {};
  Emoji? currentEmoji;
  int defaultStartIndex = 0; //for debug
  int currentEmojiIndex = 0;
  bool isExtracting = false;
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
                    emoji: currentEmoji!,
                    onColorExtracted: (color) async {
                      if (currentEmoji == null) return;
                      if (color == null) {
                        log("Color not found", name: "Emoji Color Extractor");
                        return;
                      }
                      if (colorMap[color] == null) {
                        colorMap[color] = [currentEmoji!];
                      } else {
                        colorMap[color]!.add(currentEmoji!);
                      }
                      //Add Delay
                      await Future.delayed(const Duration(milliseconds: 40));

                      setNextEmoji();
                    }),
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
                        onPressed: () => exportColorMapAsJson(),
                        child: const Text("Export"))
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

  void exportColorMapAsJson() async {
    //permission check
    if (!await Permission.storage.request().isGranted) {
      log("Permission Denied", name: "Emoji Color Extractor");
      return;
    }
    Map<String, List<String>> exportMap =
        {}; //key is color(Format:"r,g,b"), value is list of emoji
    for (var item in colorMap.entries) {
      Color color = item.key;
      exportMap['${color.red},${color.green},${color.blue}'] =
          item.value.map((e) => e.emoji).toList();
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

      log("Exported Successfully|| FileSize: ${file.lengthSync()}",
          name: "Emoji Color Extractor");
      log("File Path: ${file.path}", name: "Emoji Color Extractor");
    } catch (e) {
      log(e.toString(), name: "Emoji Color Extractor");
    }
  }
}

class EmojiColorExtractor extends StatefulWidget {
  final Emoji emoji;
  final void Function(Color?) onColorExtracted;
  const EmojiColorExtractor(
      {super.key, required this.emoji, required this.onColorExtracted});

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
      await Future.delayed(const Duration(milliseconds: 5));
      Uint8List imageData = await getImageData();
      averageColor = await getAverageImageColor(imageData, downscaleFactor: 8);
      widget.onColorExtracted(averageColor);
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

  Future<Uint8List> getImageData() async {
    var boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RepaintBoundary(
        key: repaintKey,
        child: Text(
          widget.emoji.emoji,
          style: const TextStyle(fontSize: 100),
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
