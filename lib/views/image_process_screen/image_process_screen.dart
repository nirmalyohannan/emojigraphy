import 'package:before_after/before_after.dart';
import 'package:emojigraphy/controller/image_process_controller.dart';
import 'package:emojigraphy/views/image_process_screen/widgets/image_process_tile.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageProcessScreen extends StatefulWidget {
  const ImageProcessScreen({super.key});

  @override
  State<ImageProcessScreen> createState() => _ImageProcessScreenState();
}

class _ImageProcessScreenState extends State<ImageProcessScreen> {
  double beforeAfterValue = 0.5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          const ImageProcessTile(),
          Flexible(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
              child: Container(
                decoration: BoxDecoration(),
                child: ListenableBuilder(
                    listenable: ImageProcessController.instance,
                    builder: (context, child) {
                      var controller = ImageProcessController.instance;
                      if (controller.outputImage == null) {
                        return const CircularProgressIndicator();
                      }
                      return BeforeAfter(
                        value: beforeAfterValue,
                        onValueChanged: (value) {
                          beforeAfterValue = value;
                          setState(() {});
                        },
                        before: PhotoView(
                            imageProvider: MemoryImage(controller.inputImage!)),
                        after: PhotoView(
                          backgroundDecoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(40)),
                            border: Border.all(color: Colors.white24),
                          ),
                          imageProvider: MemoryImage(controller.outputImage!),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
