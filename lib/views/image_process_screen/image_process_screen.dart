import 'package:emojigraphy/controller/image_process_controller.dart';
import 'package:emojigraphy/views/home_screen/widget/image_viewer.dart';
import 'package:emojigraphy/views/image_process_screen/widgets/image_process_tile.dart';
import 'package:flutter/material.dart';

class ImageProcessScreen extends StatelessWidget {
  const ImageProcessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          const ImageProcessTile(),
          ListenableBuilder(
              listenable: ImageProcessController.instance,
              builder: (context, child) {
                var controller = ImageProcessController.instance;
                if (controller.outputImage == null) {
                  return const CircularProgressIndicator();
                }
                return LayoutBuilder(builder: (context, constraint) {
                  return SizedBox(
                      height: constraint.maxHeight.isInfinite
                          ? 200
                          : constraint.maxHeight,
                      width: constraint.maxWidth,
                      child:
                          ImageViewer(selectedImage: controller.outputImage));
                });
              }),
          const Text("Image Process Screen"),
        ],
      )),
    );
  }
}
