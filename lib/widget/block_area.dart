import 'package:flutter/material.dart';
import '../model/block.dart';
import 'block_control.dart';
import 'block_widget.dart';
import 'control_icon.dart';
import 'relation_widget.dart';

class BlockArea extends StatefulWidget {
  /// The area where the blocks exists
  /// And where they are to be updated
  const BlockArea({
    required this.blockSet,
    super.key,
  });
  final BlockSet blockSet;

  @override
  State<BlockArea> createState() => _BlockAreaState();
}

class _BlockAreaState extends State<BlockArea> {
  @override
  void initState() {
    widget.blockSet.onUpdate = () {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// All the blocks on screen
    List<Widget> blocks = [];

    /// For all blocks
    for (Block block in widget.blockSet.allBlocks) {
      /// For all relations regarding this block
      for (BlockRelation relation in widget.blockSet.relations.where((r) =>
          r.thisBlock == block && r.type == BlockRelationType.hasReceiver)) {
        blocks.add(RelationWidget(relation: relation));
      }
      // finally add the block
      blocks.add(BlockControl(
          block: block,
          key: ObjectKey(block),
          child: BlockWidget(block: block)));
    }
    return Stack(
        children: blocks +
            <Widget>[BlockAreaControlIcons(blockSet: widget.blockSet)]);
  }
}

class BlockAreaControlIcons extends StatelessWidget {
  /// Control Icons which popup as needed inside the block area.
  /// ie: linking, ordering, deleting, etc.
  const BlockAreaControlIcons({required this.blockSet, super.key});

  final BlockSet blockSet;

  @override
  Widget build(BuildContext context) {
    /// Hides the control icons for working with selections until
    /// something is actually selected.
    if (blockSet.selectedBlocks.isEmpty) {
      return Container();
    }
    return Positioned(
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
                    function: blockSet.scaffoldKey.currentState!.openEndDrawer,
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
    );
  }
}
