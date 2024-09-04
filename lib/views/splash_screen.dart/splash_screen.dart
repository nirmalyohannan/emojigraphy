import 'package:emojigraphy/controller/color_data_controller.dart';
import 'package:emojigraphy/model/task_status.dart';
import 'package:emojigraphy/views/home_screen/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ColorDataController controller = ColorDataController.instance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await controller.loadColorData();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text('EmojiGraphy', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.statusLoadColorData == TaskStatus.success) {
                  return Icon(
                    Icons.done,
                    color: theme.colorScheme.primary,
                    size: 50,
                  );
                }
                return const CircularProgressIndicator();
              }),
        ],
      ),
    ));
  }
}
