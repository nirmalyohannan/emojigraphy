import 'package:emojigraphy/controller/image_process_controller.dart';
import 'package:emojigraphy/helper/file_manager.dart';
import 'package:emojigraphy/views/image_viewer_screen/image_viewer_screen.dart';
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
                      Text(
                        (controller.isProcessing) ? "Processing" : "Finished",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (controller.isProcessing == false &&
                              controller.outputImage != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.black),
                              label: Text("Save"),
                              onPressed: () => FileManager.instance
                                  .saveToGallery(controller.outputImage!),
                              icon: const Icon(Icons.save),
                            ),
                          if (controller.isProcessing == false &&
                              controller.outputImage != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.black),
                              label: Text("Share"),
                              onPressed: () => FileManager.instance
                                  .shareImage(controller.outputImage!),
                              icon: const Icon(Icons.share),
                            ),
                          //Fullscreen View Button
                          if (controller.isProcessing == false &&
                              controller.outputImage != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.black),
                              label: Text("View"),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewerScreen(
                                        inputImage: controller.inputImage!,
                                        outputImage: controller.outputImage!,
                                      ),
                                    ));
                              },
                              icon: const Icon(Icons.open_in_full),
                            )
                        ],
                      ),
                      if (controller.isProcessing)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
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
