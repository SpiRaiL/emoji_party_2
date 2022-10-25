library block_library;

import 'package:flutter/material.dart';
import '../model/block.dart';

class BlockWidget extends StatefulWidget {
  /// Block widget is made of two widget stacks.
  /// This is the Positioned and Draggable stack
  /// It allows ofr the movement of the Block.
  /// Below is the Block internal widget.

  const BlockWidget({required this.blockData, super.key});
  final Block blockData;

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  /// Where the x,y values for the block are stored
  double _x = 0;
  double _y = 0;

  /// Offset to account for the extra y position of the app-bar.
  /// this should be improved
  double appBarHeight = 50;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: _x,
        top: _y,
        child: InkWell(
          onTap: () {
            setState(() {
              widget.blockData.selected = !widget.blockData.selected;
            });
          },
          child: Draggable(
              feedback:
                  BlockInternal(blockData: widget.blockData, dragging: true),
              onDragEnd: (dragDetails) {
                setState(() {
                  _x = dragDetails.offset.dx;
                  _y = dragDetails.offset.dy - appBarHeight;
                });
              },
              child:
                  BlockInternal(blockData: widget.blockData, dragging: false)),
        ));
  }
}

class BlockInternal extends StatelessWidget {
  /// BlockInternal is what the user sees on the screen.
  /// This is stateless as is it rendered on creation.
  /// And again as a new instance on dragging.
  /// After trying to use the same instance for both jobs, it seems flutter
  /// just doesn't work like that

  final Block blockData;
  final bool dragging;

  const BlockInternal(
      {required this.blockData, this.dragging = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: dragging ? 0.5 : 1,
        child: Material(

            /// Stops any text being red. Needs to be after opacity.
            child: Container(

                /// Allows box decoration and padding
                decoration: BoxDecoration(
                  color: blockData.color,

                  /// The block boarder is only highlighted if the block is selected
                  border: Border.all(
                      width: 3,
                      style: blockData.selected
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
                child: Tooltip(
                    message: blockData.details,
                    child: Text(
                      blockData.displayName,
                      style: TextStyle(fontSize: dragging ? 30 : 25),
                    )))));
  }
}
