import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/block.dart';

class BlockControl extends StatefulWidget {
  /// [BlockControl] Give the user the ability to manipulate the  Block widget
  /// on the screen.
  /// This is the Positioned and Draggable stack
  /// It allows ofr the movement of the Block.

  const BlockControl({required this.block, super.key, required this.child});

  final Block block;
  final Widget child;

  @override
  State<BlockControl> createState() => _BlockControlState();
}

class _BlockControlState extends State<BlockControl> {
  /// Offset to account for the extra y position of the app-bar.
  /// this should be improved
  final double appBarHeight = 50;

  // The size of edge where the user can resize the widget
  final double sizeHandleSize = 20;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.block.offset.dx,
        top: widget.block.offset.dy,
        child: Transform.rotate(
            angle:
                widget.block.blockSet.experimental ? widget.block.rotation : 0,
            child: SizedBox(
              height: widget.block.size.height,
              width: widget.block.size.width,
              child: InkWell(
                onTap: () {
                  widget.block.toggleSelect();
                },
                child: Stack(children: [
                  _dragHandle(),

                  /// The 8 resize widgets around the edge of the block
                  _resizeHandleEdge(SystemMouseCursors.resizeLeft),
                  _resizeHandleEdge(SystemMouseCursors.resizeRight),
                  _resizeHandleEdge(SystemMouseCursors.resizeUp),
                  _resizeHandleEdge(SystemMouseCursors.resizeDown),
                  _resizeHandleCorner(SystemMouseCursors.resizeDownRight),
                  _resizeHandleCorner(SystemMouseCursors.resizeUpLeft),
                  widget.block.blockSet.experimental
                      ? _rotateHandleCorner(SystemMouseCursors.resizeDownLeft)
                      : _resizeHandleCorner(SystemMouseCursors.resizeDownLeft),
                  widget.block.blockSet.experimental
                      ? _rotateHandleCorner(SystemMouseCursors.resizeUpRight)
                      : _resizeHandleCorner(SystemMouseCursors.resizeUpRight),
                  widget.block.blockSet.experimental
                      ? _debugStackInfo()
                      : Container(),
                ]),
              ),
            )));
  }

  Widget _debugStackInfo() {
    /// In debug show the index in the stack of blocks
    /// This is the true render height of the block
    double debugSize = 10;
    int index = widget.block.blockSet.allBlocks.indexOf(widget.block);
    int height = widget.block.blockHeight;
    int childCount = widget.block.blockSet.relations
        .where((element) =>
            element.thisBlock == widget.block &&
            element.type == BlockRelationType.hasBlockChild)
        .length;
    int parentCount = widget.block.blockSet.relations
        .where((element) =>
            element.thatBlock == widget.block &&
            element.type == BlockRelationType.hasBlockChild)
        .length;
    return Positioned(
      top: debugSize,
      left: debugSize,
      child: Tooltip(
        message: "Index(in stack), Height, #Parents, #Children",
        child: SizedBox(
          height: widget.block.size.width - 2 * debugSize, //debugSize * 2,
          width: 3 * debugSize,
          child: Text("i:$index\n"
              "H:$height\n"
              "P:$parentCount\n"
              "C:$childCount"),
        ),
      ),
    );
  }

  Widget _dragHandle() {
    /// Gives the ability to drag the block around
    Block block = widget.block;

    return GestureDetector(
      onPanUpdate: (details) {
        List<Block> selected = [block];

        if (block.isSelected()) {
          selected = block.blockSet.selectedBlocks;
        }
        for (Block select in selected) {
          select.offset = Offset(select.offset.dx + details.delta.dx,
              select.offset.dy + details.delta.dy);
        }
        block.blockSet.updateCallback(block: block);
      },
      onPanEnd: (details) {
        List<Block> selected = [block];

        if (block.isSelected()) {
          selected = block.blockSet.selectedBlocks;
        }
        for (Block select in selected) {
          block.blockSet.piggyBackSort(select);
        }

        block.blockSet.updateCallback(block: block);
      },
      child: widget.child,
    );
  }

  Positioned _rotateHandleCorner(SystemMouseCursor direction) {
    /// Scale the block by dragging on the corner
    /// This currently messes up the other handles.
    /// So its only here as demo code for block rotation.

    bool left = direction == SystemMouseCursors.resizeDownLeft;
    bool top = direction == SystemMouseCursors.resizeUpRight;
    return Positioned(
        left: left ? 0 : widget.block.size.width - sizeHandleSize,
        top: top ? 0 : widget.block.size.height - sizeHandleSize,
        child: MouseRegion(
          cursor: direction,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                widget.block.rotation = details.localPosition.direction;
              });
            },
            child: SizedBox(
              width: sizeHandleSize,
              height: sizeHandleSize,
              // color: Colors.transparent,
              child: const Icon(Icons.rotate_left),
            ),
          ),
        ));
  }

  Positioned _resizeHandleCorner(SystemMouseCursor direction) {
    // Scale the block by dragging on the corner
    bool left = [
      SystemMouseCursors.resizeUpLeft,
      SystemMouseCursors.resizeDownLeft
    ].contains(direction);
    bool top = [
      SystemMouseCursors.resizeUpLeft,
      SystemMouseCursors.resizeUpRight
    ].contains(direction);
    return Positioned(
        left: left ? 0 : widget.block.size.width - sizeHandleSize,
        top: top ? 0 : widget.block.size.height - sizeHandleSize,
        child: MouseRegion(
          cursor: direction,
          child: GestureDetector(
            onPanUpdate: (details) => _updateSize(direction, details),
            onPanEnd: ((details) => widget.block.blockSet
                .piggyBackSort(widget.block, update: true)),
            child: Container(
                width: sizeHandleSize,
                height: sizeHandleSize,
                color: Colors.transparent),
          ),
        ));
  }

  Positioned _resizeHandleEdge(SystemMouseCursor direction) {
    /// Generates an area on the side of the widget that
    /// allows it to be resized along that axis
    Block block = widget.block;

    // Shorthand for directions
    bool left = direction == SystemMouseCursors.resizeLeft;
    bool right = direction == SystemMouseCursors.resizeRight;
    bool up = direction == SystemMouseCursors.resizeUp;
    bool down = direction == SystemMouseCursors.resizeDown;

    return Positioned(

        /// Where the handle is inside the block
        left: left
            ? 0
            : right
                ? block.size.width - sizeHandleSize
                : sizeHandleSize, // up and down
        top: up
            ? 0
            : down
                ? block.size.height - sizeHandleSize
                : sizeHandleSize,
        child: MouseRegion(
          cursor: direction,
          child: GestureDetector(
              onHorizontalDragUpdate: ((details) =>
                  left || right ? _updateSize(direction, details) : null),
              onHorizontalDragEnd: ((details) => left || right
                  ? block.blockSet.piggyBackSort(block, update: true)
                  : null),
              onVerticalDragUpdate: ((details) =>
                  up || down ? _updateSize(direction, details) : null),
              onVerticalDragEnd: ((details) => up || down
                  ? block.blockSet.piggyBackSort(block, update: true)
                  : null),
              child: Container(
                /// The size of the handle itself
                width: left || right
                    ? sizeHandleSize
                    : block.size.width - 2 * sizeHandleSize,
                height: up || down
                    ? sizeHandleSize
                    : block.size.height - 2 * sizeHandleSize,

                /// Change the color here to see the relevant area
                color: Colors.transparent,
              )),
        ));
  }

  void _updateSize(SystemMouseCursor direction, DragUpdateDetails details) {
    /// Called from the resize handles to real-time update the size of the
    /// widget.
    Block block = widget.block;
    // Shorthand for directions
    bool left = [
      SystemMouseCursors.resizeLeft,
      SystemMouseCursors.resizeUpLeft,
      SystemMouseCursors.resizeDownLeft
    ].contains(direction);

    bool up = [
      SystemMouseCursors.resizeUp,
      SystemMouseCursors.resizeUpLeft,
      SystemMouseCursors.resizeUpRight
    ].contains(direction);

    final double minimumBlockSize = sizeHandleSize * 3;

    return setState(() {
      /// left and up sides need to control the position as well as the scale
      if (left || up) {
        double dx = block.offset.dx;
        double dy = block.offset.dy;
        if (left && block.size.width > minimumBlockSize) {
          dx += details.delta.dx;
        }
        if (up && block.size.height > minimumBlockSize) {
          dy += details.delta.dy;
        }
        block.offset = Offset(dx, dy);
      }

      block.size = Size(
          max(minimumBlockSize,
              block.size.width + details.delta.dx * (left ? -1 : 1)),
          max(minimumBlockSize,
              block.size.height + details.delta.dy * (up ? -1 : 1)));
    });
  }
}
