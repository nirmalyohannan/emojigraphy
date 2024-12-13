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
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              // border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              // color: Colors.grey.shade300,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            (controller.isProcessing)
                                ? "Processing"
                                : "Finished",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (controller.isProcessing == false &&
                              controller.outputImage != null)
                            IconButton(
                              onPressed: () {
                                controller.saveToDownload();
                              },
                              icon: const Icon(CupertinoIcons.down_arrow),
                            ),
                          if (controller.isProcessing == false &&
                              controller.outputImage != null)
                            IconButton(
                              onPressed: () {
                                //TODO: Share Button
                              },
                              icon: const Icon(Icons.share),
                            ),
                          if (controller.isProcessing == false &&
                              controller.outputImage != null)
                            IconButton(
                              onPressed: () {
                                //TODO: Open Button
                              },
                              icon: const Icon(Icons.open_in_full),
                            )
                        ],
                      ),
                      if (controller.isProcessing)
                        Stack(
                          children: [
                            LinearProgressIndicator(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                            if (controller.progress != null)
                              LinearProgressIndicator(
                                borderRadius: BorderRadius.circular(10),
                                backgroundColor: Colors.transparent,
                                value: controller.progress,
                              ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
