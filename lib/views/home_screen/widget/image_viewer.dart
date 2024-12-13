import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key, required this.selectedImage});

  final Uint8List? selectedImage;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  TransformationController controller = TransformationController();
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
          return InkWell(
            onTap: () {
              //Zoom In and Zoom Out
              controller.value.scale(4);
              setState(() {});
            },
            child: InteractiveViewer(
              maxScale: 20,
              transformationController: controller,
              alignment: Alignment.center,
              constrained: false,
              child: Image.memory(
                widget.selectedImage!,
                height: constraints.maxHeight,
                // width: size.width * 0.8,
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.none,
              ),
            ),
          );
        }),
      ),
    );
  }
}
