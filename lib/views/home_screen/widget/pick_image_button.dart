import 'dart:typed_data';

import 'package:emojigraphy/controller/image_process_controller.dart';
import 'package:emojigraphy/helper/file_manager.dart';
import 'package:emojigraphy/views/image_process_screen/image_process_screen.dart';
import 'package:flutter/material.dart';

class PickImageButton extends StatelessWidget {
  const PickImageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(color: Colors.black),
            )),
        onPressed: () => pickImage(context),
        icon: const Icon(Icons.image, color: Colors.black),
        label: const Text(
          "Pick Image",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ));
  }

  Future<void> pickImage(BuildContext context) async {
    Uint8List? selectedImage;
    var imageFile = await FileManager.instance.pickImageFile();
    if (imageFile != null) {
      selectedImage = await imageFile.readAsBytes();
    }
    if (selectedImage == null) return;
    //add a delay
    if (!context.mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ImageProcessScreen(),
        ));
    ImageProcessController.instance.processImage(selectedImage);
  }
}
