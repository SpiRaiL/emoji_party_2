import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';

import '../model/block.dart';

class BlockWidget extends StatefulWidget {
  final Block block;

  const BlockWidget({Key? key, required this.block}) : super(key: key);

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget>
    with TickerProviderStateMixin {
  /// [BlockWidget] is what the user sees on the screen.
  /// This is stateless as is it rendered on creation.

  late final Block block;

  String mimeType = "";

  /// [AnimationController] for animation functionality
  late AnimationController _controller;

  late Animation<double> animation;

  /// Gif controller, renders gif image
  /// Using in case of missing png file for any gif media type
  late FlutterGifController controller;

  @override
  void initState() {
    block = widget.block;

    /// getting media extensions
    /// for rendering media files based on their mime types
    if (block.media.mediaType != "emoji") getMimeType();

    _controller = AnimationController(
      duration: const Duration(seconds: 72),
      vsync: this,
    )..repeat();

    animation =
        Tween<double>(begin: 0, end: (360 * pi / 180)).animate(_controller);

    controller = FlutterGifController(vsync: this);

    super.initState();
  }

  getMimeType() {
    setState(() {
      /// Gets mime type from image list
      /// based on media provided by the block
      mimeType = block.blockSet.mediaGenerator.imageList.firstWhere(
          (element) => element["path"] == block.media.media)["mime_type"]!;
    });
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
              child: block.blockSet.mediaGenerator.imageList.isEmpty
                  ? AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) =>
                          Transform.rotate(
                        angle: block.media.animated! ? animation.value : 0,
                        child: Tooltip(
                          message: block.media.media,
                          child: Text(block.media.media!),
                        ),
                      ),
                    )
                  : block.media.mediaType == "image"
                      ? mimeType == "both"
                          ? Tooltip(
                              message: block.media.name,
                              child: Image.asset(block.media.animated!
                                  ? block.media.media!.replaceAll("png", "gif")
                                  : block.media.media!),
                            )
                          : mimeType == "png"
                              ? AnimatedBuilder(
                                  animation: animation,
                                  builder:
                                      (BuildContext context, Widget? child) =>
                                          Transform.rotate(
                                    angle: block.media.animated!
                                        ? animation.value
                                        : 0,
                                    child: Tooltip(
                                        message: block.media.name,
                                        child: Image.asset(block.media.media!)),
                                  ),
                                )
                              : mimeType == "gif"
                                  ? Tooltip(
                                      message: block.media.name,
                                      child: block.media.animated!
                                          ? Image.asset(block.media.media!)
                                          : GifImage(
                                              controller: controller,
                                              image: AssetImage(
                                                  block.media.media!),
                                            ),
                                    )
                                  : AnimatedBuilder(
                                      animation: animation,
                                      builder: (BuildContext context,
                                              Widget? child) =>
                                          Transform.rotate(
                                        angle: block.media.animated!
                                            ? animation.value
                                            : 0,
                                        child: Tooltip(
                                            message: block.media.name,
                                            child: Image.asset(
                                                block.media.media!)),
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
