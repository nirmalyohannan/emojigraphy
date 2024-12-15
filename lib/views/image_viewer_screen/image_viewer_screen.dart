import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  double scale = 1.0;
  Offset offset = Offset.zero;
  Offset panStartOffset = Offset.zero;
  Offset changeInOffset = Offset.zero;
  Offset get panOffset => offset + changeInOffset;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: GestureDetector(
            onDoubleTap: () {
              if (scale > 1 || offset != Offset.zero) {
                //Already zoomed in
                //So zoom out
                scale = 1.0;
                //Also resetting the offset
                offset = Offset.zero;
              } else {
                //Zoom in
                scale = 4.0;
              }
              setState(() {});
            },
            onScaleStart: (details) {
              panStartOffset = details.focalPoint;
            },
            onScaleEnd: (details) {
              offset = offset +
                  changeInOffset; //To Fix the Offset, Comment this to reset at PanEnd
              offset = Offset(
                  clampDouble(offset.dx, -screenWidth / 4, screenWidth / 4),
                  clampDouble(offset.dy, -screenHeight / 3, screenHeight / 3));
              changeInOffset = Offset.zero;
              setState(() {});
            },
            onScaleUpdate: (details) {
              changeInOffset = details.focalPoint - panStartOffset;
              changeInOffset = changeInOffset *
                  (1 /
                      scale); //This adjusts difference in changeInOffset due to scaling

              bool isPanning = changeInOffset != Offset.zero;
              if (isPanning) {
                // offset = newOffset;
              } else {
                scale = details.scale;
              }
              setState(() {});
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: scale,
                  child: Transform.translate(
                    offset: panOffset,
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
                      offset: panOffset,
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
                      (screenWidth * beforeAfterValue) - (screenWidth / 2), 0),
                  child: Container(
                    height: screenHeight,
                    width: 5,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                      screenWidth * beforeAfterValue - (screenWidth / 2), 0),
                  child: Draggable(
                    axis: Axis.horizontal,
                    onDragUpdate: (details) {
                      setState(() {
                        beforeAfterValue = details.localPosition.dx /
                            (MediaQuery.of(context).size.width);
                      });
                    },
                    childWhenDragging: SizedBox.shrink(),
                    feedback: Container(
                        width: 10,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black),
                        )),
                    child: Container(
                      width: 10,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
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

class ImageInteractionProperty {
  double scale = 1.0;
  Offset offset = Offset.zero;
}
