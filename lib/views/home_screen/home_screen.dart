import 'package:emojigraphy/constant/assets.dart';
import 'package:emojigraphy/views/home_screen/widget/pick_image_button.dart';
import 'package:emojigraphy/views/image_viewer_screen/image_viewer_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emojigraphy/views/emoji_extractor_screen/emoji_extractor_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color.fromARGB(255, 246, 168, 4),
      // ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: Image.asset(Assets.images.homeScreenBG,
                height: size.height / 3,
                width: size.width,
                fit: BoxFit.fitWidth),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  HomeScreenCard(),
                  PickImageButton(),
                  ExtractorButton(), //Displays Only in Debug Mode
                ],
              )),
        ],
      ),
    );
  }
}

class HomeScreenCard extends StatefulWidget {
  const HomeScreenCard({
    super.key,
  });

  @override
  State<HomeScreenCard> createState() => _HomeScreenCardState();
}

class _HomeScreenCardState extends State<HomeScreenCard> {
  Uint8List? inputImage;
  Uint8List? outputImage;
  bool isLoading = true;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadImage();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Builder(builder: (context) {
      var dimension = size.width < size.height ? size.width : size.height;
      dimension = dimension / 1.5;
      return Transform.translate(
        offset: Offset(0, -(size.height / 10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: dimension,
            width: dimension,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 205, 191, 161),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 2))
                ]),
            child: Builder(builder: (context) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (inputImage == null || outputImage == null) {
                return const Center(child: Text("Error"));
              }

              return ImageViewerScreen(
                  hideAppBar: true,
                  outputImage: outputImage!,
                  inputImage: inputImage!);
            }),
          ),
        ),
      );
    });
  }

  Future<void> loadImage() async {
    isLoading = true;
    setState(() {});

    final ByteData inputBytes =
        await rootBundle.load(Assets.images.sample1Input);
    final Uint8List inputImage = inputBytes.buffer.asUint8List();

    final ByteData outputBytes =
        await rootBundle.load(Assets.images.sample1Output);
    final Uint8List outputImage = outputBytes.buffer.asUint8List();

    setState(() {
      isLoading = false;
      this.inputImage = inputImage;
      this.outputImage = outputImage;
    });
  }
}

class ExtractorButton extends StatelessWidget {
  const ExtractorButton({super.key});

  @override
  Widget build(BuildContext context) {
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
