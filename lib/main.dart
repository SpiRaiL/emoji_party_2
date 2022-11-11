import 'package:emoji_party/widget/block_control.dart';
import 'package:emoji_party/widget/control_icon.dart';
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

  /// Allows opening the drawer from other places
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String emojiSearchString = "";

  void applySetState() {
    setState(() {});
  }

  @override
  void initState() {
    blockSet = BlockSet(setUpdateCallback: applySetState);
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
              leading: ControlIcon(
                  icon: Icons.add,
                  function: blockSet.addBlock,
                  tooltip: "add a new block"),

              actions: [
                ControlIcon(
                    icon: Icons.select_all,
                    function: blockSet.selectAllOrNone,
                    tooltip: blockSet.selectedBlocks.isEmpty
                        ? "select all"
                        : "select none"),
                ControlIcon(
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
      blocks.add(BlockControl(
          block: block,
          key: ObjectKey(block),
          child: BlockWidget(block: block)));
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
                          ? ControlIcon(
                              icon: Icons.link_off,
                              function: blockSet.linkForward,
                              tooltip: "Remove forward link")
                          : ControlIcon(
                              icon: Icons.link,
                              function: blockSet.linkForward,
                              tooltip: "Create forward link")
                      : Container(),
                  blockSet.selectedBlocks.length >= 2
                      ? blockSet.blocksAreLinked(forward: false)
                          ? ControlIcon(
                              icon: Icons.link_off,
                              function: blockSet.linkReverse,
                              tooltip: "Remove reverse link")
                          : ControlIcon(
                              icon: Icons.link,
                              function: blockSet.linkReverse,
                              tooltip: "Create reverse link")
                      : Container(),
                  ControlIcon(
                      icon: Icons.arrow_upward,
                      function: blockSet.toTop,
                      tooltip: "Move selected to top"),
                  ControlIcon(
                      icon: Icons.arrow_downward,
                      function: blockSet.toBottom,
                      tooltip: "Move select to bottom"),
                  ControlIcon(
                      icon: Icons.delete,
                      function: blockSet.deleteSelected,
                      tooltip: "Delete selected blocks"),
                ],
              ),
              Row(
                children: [
                  ControlIcon(
                      icon: Icons.search,
                      function: _scaffoldKey.currentState!.openEndDrawer,
                      tooltip: "Change emoji")
                ],
              ),
              Row(
                children: [
                  ControlIcon(
                      icon: Icons.refresh,
                      function: blockSet.randomEmoji,
                      tooltip: "Random emojis"),
                ],
              )
            ],
          ),
        ),
      )
    ];
  }
}
