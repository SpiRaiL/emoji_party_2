library block_library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/block.dart';

class BlockWidget extends StatefulWidget {
  /// Block widget is made of two widget stacks.
  /// This is the Positioned and Draggable stack
  /// It allows ofr the movement of the Block.
  /// Below is the Block internal widget.

  const BlockWidget({required this.block, super.key});
  final Block block;

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  /// Offset to account for the extra y position of the app-bar.
  /// this should be improved
  final double appBarHeight = 50;

  // The size of edge where the user can resize the widget
  final double sizeHandleSize = 10;
  final double minimumBlockSize = 25;

  @override
  Widget build(BuildContext context) {
    Block block = widget.block;
    return Positioned(
        left: block.offset.dx,
        top: block.offset.dy,
        child: InkWell(
          onTap: () {
            setState(() {
              block.toggleSelect();
            });
          },
          child: Stack(children: [
            Draggable(

                /// Check if selected here
                feedback: block.isSelected()
                    ? BlockSelectedInternal(block: block)
                    : BlockInternal(block: block, dragging: true),
                onDragEnd: (dragDetails) {
                  /// Get the distance moved
                  Offset offsetDiff =
                      dragDetails.offset.translate(0, -appBarHeight) -
                          block.offset;

                  if (block.isSelected()) {
                    /// Move and update all the selected blocks
                    for (Block block in block.blockSet.selectedBlocks) {
                      block.offset += offsetDiff;
                    }
                    block.blockSet.setStateCallback();
                  } else {
                    /// Just move and update this block
                    setState(() {
                      block.offset += offsetDiff;
                    });
                  }
                },
                child: BlockInternal(block: block, dragging: false)),
            _resizeHandle(SystemMouseCursors.resizeLeft),
            _resizeHandle(SystemMouseCursors.resizeRight),
            _resizeHandle(SystemMouseCursors.resizeUp),
            _resizeHandle(SystemMouseCursors.resizeDown),
          ]),
        ));
  }

  Positioned _resizeHandle(SystemMouseCursor direction) {
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
              onVerticalDragUpdate: ((details) =>
                  up || down ? _updateSize(direction, details) : null),
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
    bool left = direction == SystemMouseCursors.resizeLeft;
    bool up = direction == SystemMouseCursors.resizeUp;
    return setState(() {
      if (left || up) {
        block.offset = Offset(block.offset.dx + details.delta.dx,
            block.offset.dy + details.delta.dy);
      }

      block.size = Size(
          max(minimumBlockSize,
              block.size.width + details.delta.dx * (left ? -1 : 1)),
          max(minimumBlockSize,
              block.size.height + details.delta.dy * (up ? -1 : 1)));
    });
  }
}

class BlockSelectedInternal extends StatelessWidget {
  /// This is used when we drag a selected item
  /// Rather than showing just one BlockInternal dragging,
  /// We also need to show all the other selected blocks dragging

  const BlockSelectedInternal({required this.block, super.key});
  final Block block;

  @override
  Widget build(BuildContext context) {
    /// A large container housing is needed to allow this stack to exist in the
    /// parent draggable stack. Otherwise the system crashes.
    /// It has something to do with other widgets not knowing what size to be.
    ///
    /// The next issue is that the container starts at the top left of the
    /// dragging widget. As such no selected items above or left will be visible
    /// To solve this we translate the entire container back to top-left corner
    /// of the page. (try with Debug painting)
    /// This is easy info, since we have stored this value in the blocks
    /// co-ordinates. Theoretically a Positioned widget would solve this.
    /// However positioned has the same issue as above. As such, we
    /// can solve this instead using the transform function in the Container.
    return Container(
        height: 5000,
        width: 5000,
        transform:
            Matrix4.translationValues(-block.offset.dx, -block.offset.dy, 0),
        clipBehavior: Clip.none,
        child: Stack(
            children: block.blockSet
                .selectedInOrder()
                .map<Widget>((selectBlock) => Positioned(

                    /// This "should" be the difference between this
                    /// blocks position and the one that we started dragging
                    /// however, the difference is already taken into account
                    /// by the Matrix4.translation.
                    left: selectBlock.offset.dx,
                    top: selectBlock.offset.dy,
                    child: BlockInternal(
                      block: selectBlock,
                      dragging: true,
                    )))
                .toList()));
  }
}

class BlockInternal extends StatelessWidget {
  /// BlockInternal is what the user sees on the screen.
  /// This is stateless as is it rendered on creation.
  /// And again as a new instance on dragging.
  /// After trying to use the same instance for both jobs, it seems flutter
  /// just doesn't work like that

  final Block block;
  final bool dragging;
  // Internal block offset relative to parent

  static const double resizeBorderWidth = 20;

  const BlockInternal({
    required this.block,
    this.dragging = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: dragging ? 0.75 : 1,
        child: Material(

            /// Stops any text being red. Needs to be after opacity.
            child: Container(
                height: block.size.height * (dragging ? 1.2 : 1),
                width: block.size.width * (dragging ? 1.2 : 1),

                /// Allows box decoration and padding
                decoration: BoxDecoration(
                  color: block.color,

                  /// The block boarder is only highlighted if the block is selected
                  border: Border.all(
                      width: 3,
                      style: block.isSelected()
                          ? BorderStyle.solid
                          : BorderStyle.none,
                      color: const Color.fromARGB(255, 255, 107, 107)),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 66, 66, 66),
                      spreadRadius: 0,
                      offset: Offset(2, 2),
                      blurStyle: BlurStyle.normal,
                      blurRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Tooltip(
                        message: block.details,
                        child: Text(
                          block.displayName,
                          // style: TextStyle(fontSize: dragging ? 30 : 25),
                        ))))));
  }
}
