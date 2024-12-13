import 'package:emojigraphy/controller/image_process_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageProcessTile extends StatelessWidget {
  const ImageProcessTile({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = ImageProcessController.instance;
    return ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.shade300,
            ),
            child: Row(
              children: [
                if (controller.inputImage != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.memory(controller.inputImage!,
                        height: 100, width: 100, fit: BoxFit.cover),
                  ),
                Flexible(
                  child: Column(
                    children: [
                      Text(
                          "Speed: ${controller.pixelPerSecond.toStringAsFixed(2)} pixels/second"),
                      if (controller.isProcessing)
                        Stack(
                          children: [
                            LinearProgressIndicator(
                                borderRadius: BorderRadius.circular(10)),
                            LinearProgressIndicator(
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: Colors.transparent,
                              value: 0.5,
                            ),
                          ],
                        ),
                      if (controller.isProcessing == false &&
                          controller.outputImage != null)
                        IconButton(
                          onPressed: () {
                            controller.saveToDownload();
                          },
                          icon: const Icon(Icons.download),
                        )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
