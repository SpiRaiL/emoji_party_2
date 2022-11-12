import 'package:flutter/material.dart';
import 'model/block.dart';
import 'widget/block_area.dart';
import 'widget/control_buttons.dart';
import 'widget/emoji_drawer.dart';

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

  @override
  Widget build(BuildContext context) {
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
                  function: blockSet.addBlock,
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
                emojiGenerator: blockSet.emojiGenerator,
                callback: (emojiName) {
                  blockSet.changeEmoji(emojiName);
                }),

            /// Finally all the blocks on the screen
            body: BlockArea(blockSet: blockSet)));
  }
}
