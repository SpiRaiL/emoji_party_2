import 'dart:math';

import 'package:emoji_party/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/block.dart';
import 'block_control.dart';
import 'block_widget.dart';
import 'control_buttons.dart';
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
  late HomeController controller;

  @override
  void initState() {
    controller = Get.find();
    widget.blockSet.onUpdate = () {
      setState(() {
        widget.blockSet.mediaGenerator.imageList = controller.imagesList;
      });
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
  BlockAreaControlIcons({required this.blockSet, super.key});

  final BlockSet blockSet;

  final HomeController controller = Get.find();

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
                        ? ControlButton(
                            icon: Icons.link_off,
                            function: blockSet.linkForward,
                            tooltip: "Remove forward link")
                        : ControlButton(
                            icon: Icons.link,
                            function: blockSet.linkForward,
                            tooltip: "Create forward link")
                    : Container(),
                blockSet.selectedBlocks.length >= 2
                    ? blockSet.blocksAreLinked(forward: false)
                        ? ControlButton(
                            icon: Icons.link_off,
                            function: blockSet.linkReverse,
                            tooltip: "Remove reverse link")
                        : ControlButton(
                            icon: Icons.link,
                            function: blockSet.linkReverse,
                            tooltip: "Create reverse link")
                    : Container(),
                ControlButton(
                    icon: Icons.arrow_upward,
                    function: blockSet.toTop,
                    tooltip: "Move selected to top"),
                ControlButton(
                    icon: Icons.arrow_downward,
                    function: blockSet.toBottom,
                    tooltip: "Move select to bottom"),
                ControlButton(
                    icon: Icons.delete,
                    function: blockSet.deleteSelected,
                    tooltip: "Delete selected blocks"),
              ],
            ),
            Row(
              children: [
                ControlButton(
                    icon: Icons.refresh,
                    function: () {
                      blockSet.randomMedia(controller.imagesList.isNotEmpty
                          ? true
                          : Random().nextBool());
                    },
                    tooltip: "Random emojis"),
                ControlButton(
                    icon: Icons.search,
                    function: blockSet.scaffoldKey.currentState!.openEndDrawer,
                    tooltip: "Change emoji")
              ],
            ),
            Row(
              children: [
                ControlButton(
                    icon: Icons.animation,
                    function: blockSet.animateMedia,
                    tooltip: "Animate emojis"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
