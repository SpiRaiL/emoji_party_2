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
  List<Block> blocks = [Block(generate: true, emoji: true)];

  /// Function could be improved with a selected blocks group
  /// List<Block> selectedBlocks = [];

  static const Color iconColor = Colors.blue;

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
                  onPressed: _addBlock

                  /// do something
                  ),

              actions: [
                IconButton(
                    onPressed: _reGenerate,
                    icon: const Icon(Icons.refresh, color: iconColor)),
                IconButton(
                    onPressed: _toTop,
                    icon: const Icon(Icons.arrow_upward, color: iconColor)),
                IconButton(
                    onPressed: _toBottom,
                    icon: const Icon(Icons.arrow_downward, color: iconColor)),
                IconButton(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete, color: iconColor)),
                IconButton(
                    onPressed: _selectAllOrNone,
                    icon: const Icon(Icons.select_all, color: iconColor)),
              ],
            ),
            body: InteractiveViewer(
                child: Stack(
              clipBehavior: Clip.none,

              /// Maps each item in blocks to a widget.
              /// Object key is needed for _deleteSelected
              /// lookup object keys for more info
              children: blocks
                  .map<Widget>((block) => BlockWidget(
                        key: ObjectKey(block),
                        blockData: block,
                      ))
                  .toList(),
            ))));
  }

  /// Various button functions.
  void _addBlock() {
    /// Add a block to the list of blocks
    setState(() {
      blocks.add(Block(generate: true, emoji: true));
    });
  }

  void _deleteSelected() {
    setState(() {
      blocks.removeWhere((block) => block.selected);
    });
  }

  void _selectAllOrNone() {
    int count = blocks.where((block) => block.selected).length;
    setState(() {
      /// If they are all selected
      if (count == blocks.length) {
        /// Select None
        for (Block block in blocks) {
          block.selected = false;
        }
      } else {
        /// Select all
        for (Block block in blocks) {
          block.selected = true;
        }
      }
    });
  }

  void _toTop() {
    /// Move selected items to the top of the stack
    /// ie: the end of the list
    setState(() {
      List<Block> selected = blocks.where((block) => block.selected).toList();

      for (Block block in selected) {
        int index = blocks.indexOf(block);
        blocks.insert(blocks.length - 1, blocks.removeAt(index));
      }
    });
  }

  void _toBottom() {
    /// Move selected items to the bottom of the stack
    /// ie: the start of the list
    setState(() {
      List<Block> selected = blocks.where((block) => block.selected).toList();

      for (Block block in selected.reversed) {
        int index = blocks.indexOf(block);
        blocks.insert(0, blocks.removeAt(index));
      }
    });
  }

  void _reGenerate() {
    /// Re-roll the emoji, in the same place in the stack
    setState(() {
      List<Block> selected = blocks.where((block) => block.selected).toList();

      for (Block block in selected) {
        block.generateData(emoji: true);
      }
    });
  }
}
