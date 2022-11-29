import 'package:emoji_party/controller/home_controller.dart';
import 'package:emoji_party/widget/emoji_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/block.dart';
import 'widget/block_area.dart';
import 'widget/control_buttons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// This is the main class of "blocks" that hold the data for the
  /// objects we will drag on the screen.
  /// but only the data
  /// the the "name" which can be just an emoji
  /// and the background color.
  late BlockSet blockSet = BlockSet();

  final controller = Get.put(HomeController());

  @override
  void initState() {
    controller.loadImagesFromAssets(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(controller.imagesList);
    return MaterialApp(
      title: 'Emoji party',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: Scaffold(
        key: blockSet.scaffoldKey,
        appBar: AppBar(
          title: const Text("Add emoji to the party"),

          /// Leading instead of actions so its not covered by debug
          /// This is the button that generate the blocks
          leading: ControlButton(
              icon: Icons.add,
              function: () async {
                setState(() {});

                if (controller.imagesList.isEmpty) {
                  blockSet.addBlock(false);
                } else {
                  blockSet.addBlock(true);
                }
              },
              tooltip: "add a new block"),

          actions: [
            ControlButton(
                icon: Icons.select_all,
                function: blockSet.selectAllOrNone,
                tooltip: blockSet.selectedBlocks.isEmpty
                    ? "select all"
                    : "select none"),
            ControlButton(
                icon: Icons.info,
                function: () {
                  /// Toggles experimental mode and adds extra debug data to the screens
                  blockSet.experimental = !blockSet.experimental;
                  setState(() {});
                },
                tooltip: "Show experimental data"),
          ],
        ),
        endDrawer: EmojiDrawer(
            mediaGenerator: blockSet.mediaGenerator,
            callback: (emojiName, imageName) {
              if (emojiName.length > 0) {
                blockSet.changeMedia(emojiName, false);
              } else if (imageName.length > 0) {
                blockSet.changeMedia(imageName, true);
              } else {
                print("-- NO data");
              }
            }),

        /// Finally all the blocks on the screen
        body: Obx(() => controller.isLoading.value
            ? const CircularProgressIndicator()
            : BlockArea(blockSet: blockSet)),
      ),
    );
  }
}
