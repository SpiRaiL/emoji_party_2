import 'package:flutter/material.dart';
import 'model/block.dart';
import 'widget/block_widget.dart';
import 'widget/emoji_drawer.dart';
import 'widget/relation_widget.dart';

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

  /// Allows opening the drawer from other places
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String emojiSearchString = "";

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
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text("Add emoji to the party"),

              /// Leading instead of actions so its not covered by debug
              /// This is the button that generate the blocks
              leading: _formattedIcon(
                  Icons.add, blockSet.addBlock, "add a new block"),

              actions: [
                _formattedIcon(
                    Icons.select_all,
                    blockSet.selectAllOrNone,
                    blockSet.selectedBlocks.isEmpty
                        ? "select all"
                        : "select none"),
                _formattedIcon(
                    Icons.info, _experimental, "Show experimental data"),
              ],
            ),
            endDrawer: EmojiDrawer(
                emojiGenerator: blockSet.emojiGenerator,
                initialSearchString: emojiSearchString,
                callback: onDrawerSelect),

            /// Finally all the blocks on the screen
            body: Stack(children: _blocks() + _selectIcons())));
  }

  void onDrawerSelect(String emojiName, String searchString) {
    /// Handles return functions from the search
    blockSet.changeEmoji(emojiName);
    emojiSearchString = searchString;
  }

  List<Widget> _blocks() {
    /// All the blocks on screen
    List<Widget> blocks = [];

    /// For all blocks
    for (Block block in blockSet.allBlocks) {
      /// For all relations regarding this block
      for (BlockRelation relation in blockSet.relations.where((r) =>
          r.thisBlock == block && r.type == BlockRelationType.hasReceiver)) {
        blocks.add(RelationWidget(relation: relation));
      }
      // finally add the block
      blocks.add(BlockWidget(block: block, key: ObjectKey(block)));
    }
    return blocks;
  }

  List<Widget> _selectIcons() {
    /// Hides the control icons for working with selections until
    /// something is actually selected.
    if (blockSet.selectedBlocks.isEmpty) {
      return [];
    }
    return [
      Positioned(
        top: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  blockSet.selectedBlocks.length >= 2
                      ? blockSet.blocksAreLinked(forward: true)
                          ? _formattedIcon(Icons.link_off, blockSet.linkForward,
                              "Remove forward link")
                          : _formattedIcon(Icons.link, blockSet.linkForward,
                              "Create forward link")
                      : Container(),
                  blockSet.selectedBlocks.length >= 2
                      ? blockSet.blocksAreLinked(forward: false)
                          ? _formattedIcon(Icons.link_off, blockSet.linkReverse,
                              "Remove reverse link")
                          : _formattedIcon(Icons.link, blockSet.linkReverse,
                              "Create reverse link")
                      : Container(),
                  _formattedIcon(Icons.arrow_upward, blockSet.toTop,
                      "Move selected to top"),
                  _formattedIcon(Icons.arrow_downward, blockSet.toBottom,
                      "Move select to bottom"),
                  _formattedIcon(Icons.delete, blockSet.deleteSelected,
                      "Delete selected blocks"),
                ],
              ),
              Row(
                children: [
                  _formattedIcon(Icons.search, () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  }, "Change emoji")
                ],
              ),
              Row(
                children: [
                  _formattedIcon(
                      Icons.refresh, blockSet.randomEmoji, "Random emojis"),
                ],
              )
            ],
          ),
        ),
      )
    ];
  }

  _formattedIcon(IconData icon, void Function() function, String tooltip) {
    /// Shorthand for the onscreen icons in the app_bar
    /// and in the select icons popups
    return IconButton(
        onPressed: () {
          setState(() {
            function();
          });
        },
        icon: Tooltip(message: tooltip, child: Icon(icon, color: iconColor)));
  }

  void _experimental() {
    /// Toggles experimental mode and adds extra debug data to the screens
    blockSet.experimental = !blockSet.experimental;
  }
}
