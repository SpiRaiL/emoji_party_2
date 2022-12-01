import 'dart:math';

import 'package:emoji_party/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  /// [AnimationController] for animation functionality
  late AnimationController _controller;

  late Animation<double> animation;

  late HomeController controller;

  @override
  void initState() {
    block = widget.block;
    controller = Get.find();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    animation =
        Tween<double>(begin: 0, end: (45 * pi / 180)).animate(_controller);

    super.initState();
  }

  bool getAnimatedImage() {
    if (controller.imagesList
        .contains(block.media.media!.replaceAll("png", "gif"))) {
      return true;
    } else {
      return false;
    }
    // block.media.media!.replaceAll("png", "gif");
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
          color: block.media.color,

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
            width: 70,
            height: 70,
            child: FittedBox(
              fit: BoxFit.contain,
              child: controller.imagesList.isEmpty
                  ? AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) =>
                          Transform.rotate(
                        angle: block.media.animated! ? animation.value : 0,
                        child: Tooltip(
                          message: block.media.name,
                          child: Text(block.media.media!),
                        ),
                      ),
                    )
                  : block.media.mediaType == "image"
                      ? block.media.animated! && getAnimatedImage()
                          ? Tooltip(
                              message: block.media.name,
                              child: Image.asset(block.media.animated!
                                  ? block.media.media!.replaceAll("png", "gif")
                                  : block.media.media!),
                            )
                          : AnimatedBuilder(
                              animation: animation,
                              builder: (BuildContext context, Widget? child) =>
                                  Transform.rotate(
                                angle:
                                    block.media.animated! ? animation.value : 0,
                                child: Tooltip(
                                  message: block.media.name,
                                  child: Image.asset(block.media.media!),
                                ),
                              ),
                            )
                      : AnimatedBuilder(
                          animation: animation,
                          builder: (BuildContext context, Widget? child) =>
                              Transform.rotate(
                            angle: block.media.animated! ? animation.value : 0,
                            child: Tooltip(
                              message: block.media.name,
                              child: Text(block.media.media!),
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
