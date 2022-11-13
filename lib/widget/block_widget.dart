import 'package:flutter/material.dart';

import '../model/block.dart';

class BlockWidget extends StatelessWidget {
  /// [BlockWidget] is what the user sees on the screen.
  /// This is stateless as is it rendered on creation.

  final Block block;

  static const double resizeBorderWidth = 20;

  const BlockWidget({
    required this.block,
    super.key,
  });

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
                  style:
                      block.isSelected() ? BorderStyle.solid : BorderStyle.none,
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
              width: 80,
              height: 80,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Transform.rotate(
                  angle: block.emoji.animated ? 45 : 0,
                  child: Tooltip(
                      message: block.emoji.emojiName,
                      child: Text(
                        block.emoji.emoji,
                      )),
                ),
              ),
            ))));
  }
}
