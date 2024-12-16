import 'package:emojigraphy/views/home_screen/widget/pick_image_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:emojigraphy/views/emoji_extractor_screen/emoji_extractor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                PickImageButton(),
                extractorButton(),
              ],
            )),
      ),
    );
  }

  Widget extractorButton() {
    if (kDebugMode) {
      return TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EmojiExtractorScreen()));
          },
          child: const Text("Extractor"));
    }
    return const SizedBox.shrink();
  }
}
