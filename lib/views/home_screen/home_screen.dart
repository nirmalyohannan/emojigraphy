import 'dart:io';
import 'package:emojigraphy/controller/image_process_controller.dart';
import 'package:emojigraphy/views/emoji_extractor_screen/emoji_extractor_screen.dart';
import 'package:emojigraphy/views/home_screen/widget/image_viewer.dart';
import 'package:emojigraphy/views/image_process_screen/image_process_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? selectedImage;

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
                          child: ImageViewer(selectedImage: selectedImage)),
                    pickImageButton(),
                    extractorButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget extractorButton() {
    if (kDebugMode) {
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
          if (selectedImage == null) return;
          //add a delay
          if (!mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ImageProcessScreen(),
              ));
          ImageProcessController.instance.processImage(selectedImage!);
        },
        icon: const Icon(Icons.image, color: Colors.black),
        label: const Text(
          "Pick Image",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ));
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
}
