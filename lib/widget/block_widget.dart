import 'dart:math';

import 'package:flutter/material.dart';

import '../model/block.dart';

class BlockWidget extends StatefulWidget {
  final Block block;

  const BlockWidget({Key? key, required this.block}) : super(key: key);

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget>
    with SingleTickerProviderStateMixin {
  /// [BlockWidget] is what the user sees on the screen.
  /// This is stateless as is it rendered on creation.

  late final Block block;

  static const double resizeBorderWidth = 20;

  /// [AnimationController] for animation functionality
  late AnimationController _controller;

  late Animation<double> animation;

  @override
  void initState() {
    block = widget.block;

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    animation =
        Tween<double>(begin: 0, end: (45 * pi / 180)).animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      /// Stops any text being red. Needs to be after opacity.
      child: Container(
        /// Allows box decoration and padding
        decoration: BoxDecoration(
          color: block.emoji.color,

          /// The block boarder is only highlighted if the block is selected
          border: Border.all(
              width: 3,
              style: block.isSelected() ? BorderStyle.solid : BorderStyle.none,
              // The first selected should be a lighter share of orange
              color: block.blockSet.selectedBlocks.indexOf(block) == 0
                  ? const Color.fromARGB(255, 255, 138, 28)
                  : const Color.fromARGB(255, 255, 107, 107)),
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
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: FittedBox(
              fit: BoxFit.contain,
              child: AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) =>
                    Transform.rotate(
                  angle: block.emoji.animated ? animation.value : 0,
                  child: Tooltip(
                    message: block.emoji.emojiName,
                    child: Text(
                      block.emoji.emoji,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
