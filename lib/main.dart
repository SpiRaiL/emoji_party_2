import 'package:flutter/material.dart';
import 'model/block.dart';
import 'widget/block_widget.dart';

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
  late BlockSet blockSet;

  /// Function could be improved with a selected blocks group
  /// List<Block> selectedBlocks = [];

  static const Color iconColor = Colors.blue;

  void applySetState() {
    setState(() {});
  }

  @override
  void initState() {
    blockSet = BlockSet(setStateCallback: applySetState);
    super.initState();
  }

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
            appBar: AppBar(
              title: const Text("Add emoji to the party"),

              /// Leading instead of actions so its not covered by debug
              /// This is the button that generate the blocks
              leading: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      blockSet.addBlock();
                    });
                  }),

              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        blockSet.reGenerate();
                      });
                    },
                    icon: const Icon(Icons.refresh, color: iconColor)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        blockSet.toTop();
                      });
                    },
                    icon: const Icon(Icons.arrow_upward, color: iconColor)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        blockSet.toBottom();
                      });
                    },
                    icon: const Icon(Icons.arrow_downward, color: iconColor)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        blockSet.deleteSelected();
                      });
                    },
                    icon: const Icon(Icons.delete, color: iconColor)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        blockSet.selectAllOrNone();
                      });
                    },
                    icon: const Icon(Icons.select_all, color: iconColor)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        blockSet.experimental = !blockSet.experimental;
                      });
                    },
                    icon: const Icon(Icons.info, color: iconColor)),
              ],
            ),
            body: Stack(
                children: blockSet.allBlocks
                    .map<Widget>((block) => BlockWidget(
                          block: block,
                          key: ObjectKey(block),
                        ))
                    .toList())));
  }
}
