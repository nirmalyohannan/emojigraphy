import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:emojigraphy/helper/file_manager.dart';
import 'package:emojigraphy/views/image_viewer_screen/widgets/interactive_view.dart';

class ImageViewerScreen extends StatefulWidget {
  final Uint8List outputImage;
  final Uint8List inputImage;
  const ImageViewerScreen(
      {super.key, required this.outputImage, required this.inputImage});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  double screenWidth = 0;
  double screenHeight = 0;
  double beforeAfterValue = 0.5;
  InteractionController imageController = InteractionController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      imageController.imageAreaHeight = screenHeight;
      imageController.imageAreaWidth = screenWidth;
      setState(() {});
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        actions: [
          TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () =>
                  FileManager.instance.saveToGallery(widget.outputImage),
              icon: Icon(Icons.save),
              label: Text("Save")),
          IconButton(
              color: Colors.white,
              icon: Icon(Icons.share),
              onPressed: () =>
                  FileManager.instance.shareImage(widget.outputImage))
        ],
      ),
      body: SafeArea(
        child: InteractiveView(
            controller: imageController,
            builder: (scale, offset) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: scale,
                    child: Transform.translate(
                      offset: offset,
                      child: Image.memory(
                        widget.inputImage,
                        fit: BoxFit.cover,
                        width: screenWidth,
                        height: screenHeight,
                      ),
                    ),
                  ),
                  ClipRect(
                    clipper: BeforeAfterClipper(
                      height: MediaQuery.of(context).size.height,
                      width: screenWidth * beforeAfterValue,
                    ),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: scale,
                      child: Transform.translate(
                        offset: offset,
                        child: Image.memory(
                          widget.outputImage,
                          width: screenWidth,
                          height: screenHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(
                        (screenWidth * beforeAfterValue) - (screenWidth / 2),
                        0),
                    child: const SliderLine(),
                  ),
                  Transform.translate(
                    offset: Offset(
                        screenWidth * beforeAfterValue - (screenWidth / 2), 0),
                    child: Draggable(
                      axis: Axis.horizontal,
                      onDragUpdate: (details) {
                        beforeAfterValue =
                            details.localPosition.dx / screenWidth;
                        setState(() {});
                      },
                      feedback: const SliderThumb(),
                      child: const SliderThumb(),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}

class SliderLine extends StatelessWidget {
  const SliderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: 5,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)),
    );
  }
}

class BeforeAfterClipper extends CustomClipper<Rect> {
  final double height;
  final double width;
  BeforeAfterClipper({
    required this.height,
    required this.width,
  });

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0, // Left
      0, // Top
      width, // Width
      height, // Height
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class SliderThumb extends StatelessWidget {
  const SliderThumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Row(
        children: [
          Icon(
            Icons.arrow_left,
            color: Colors.black,
          ),
          Icon(Icons.arrow_right, color: Colors.black),
        ],
      ),
    );
  }
}
