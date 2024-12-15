import 'package:emojigraphy/views/image_process_screen/widgets/image_process_tile.dart';
import 'package:flutter/material.dart';

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
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey),
                child: Placeholder(),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
