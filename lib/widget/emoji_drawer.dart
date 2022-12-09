import 'dart:ui' as ui;

import 'package:emoji_party/model/media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';

class EmojiDrawer extends StatefulWidget {
  /// A pop-up draw that lists all the emojis
  /// and allows for a search function
  /// Exists in its own stateful widget so that search updates do not
  /// cause entire reloads of the canvas
  /// [emojiGenerator] is a link to the list of emojis available
  /// [callback(emojiName, searchString)] is what to do when one is selected.
  /// [initialSearchString] is needed if you want to start with a search
  /// this is also needed if you want to save this string in the parent for the
  /// next time.
  const EmojiDrawer({
    required this.mediaGenerator,
    required this.callback,
    super.key,
    this.closeDrawerOnSelect = true,
  });

  final MediaGenerator mediaGenerator;
  final Function callback;
  final bool closeDrawerOnSelect;

  @override
  State<EmojiDrawer> createState() => _EmojiDrawerState();
}

class _EmojiDrawerState extends State<EmojiDrawer>
    with TickerProviderStateMixin {
  /// For filtering the emoji drawer
  final TextEditingController _editingController = TextEditingController();

  /// Boolean value to check if search string exist
  bool imageExist = true;
  bool emojiExist = true;

  /// Renders gif image
  /// [i-e] Will only draw first frame of gif image if
  /// animation controller is not provided to it
  /// Using in case of missing png file for any media
  late FlutterGifController controller;

  @override
  void initState() {
    /// Setup the search string if there is one already typed in by the user
    _editingController.text = widget.mediaGenerator.searchString;

    /// Gif controllers
    controller = FlutterGifController(vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      widget.mediaGenerator.searchString = value;

                      /// Checking if image exists for searched string
                      if (widget.mediaGenerator
                          .imagesMatchingSearchString()
                          .isEmpty) {
                        imageExist = false;
                      } else {
                        imageExist = true;
                      }

                      /// Check if emoji exists for searched string
                      if (widget.mediaGenerator
                          .emojisMatchingSearchString()
                          .isEmpty) {
                        emojiExist = false;
                      } else {
                        emojiExist = true;
                      }
                    });
                  },
                  controller: _editingController,
                  decoration: const InputDecoration(
                      labelText: "Search",
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),

              /// Listing images if exists in asset folder
              widget.mediaGenerator.imageList.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imageExist
                            ? const Padding(
                                padding: EdgeInsets.only(left: 25.0),
                                child: Text(
                                  'Custom',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        Column(
                          /// for all the available images
                          children: widget.mediaGenerator
                              .imagesMatchingSearchString()
                              .map(
                            (image) {
                              /// Images name with path details
                              String imageString =
                                  "assets/custom/images/$image.png";

                              /// Check and return if image exists in image list
                              List<Map<String, String>> valueExists = widget
                                  .mediaGenerator.imageList
                                  .where((element) =>
                                      element["path"] == imageString)
                                  .toList();

                              /// Make a clickable row
                              return InkWell(
                                onHover: (bool value) {
                                  if (value) {
                                    setState(() {
                                      imageString =
                                          "assets/custom/images/$image.gif";
                                    });
                                  }
                                },
                                onTap: () {
                                  widget.callback(
                                      "",
                                      valueExists.isNotEmpty
                                          ? imageString
                                          : "assets/custom/images/$image.gif",
                                      image);

                                  // close the drawer
                                  if (widget.closeDrawerOnSelect) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 60,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: valueExists.isNotEmpty
                                            ? Image.asset(imageString)
                                            : GifImage(
                                                controller: controller,
                                                image: AssetImage(
                                                    "assets/custom/images/$image.gif"),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(image),
                                    )
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    )
                  : Container(),

              /// Listing images on top of emoji list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  emojiExist
                      ? const Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, top: 8.0, bottom: 12.0),
                          child: Text(
                            'Emojis',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Column(
                    /// for all the available emojis
                    children: widget.mediaGenerator
                        .emojisMatchingSearchString()
                        .map(
                          (emoji) =>

                              /// Make a clickable row
                              InkWell(
                            onTap: () {
                              widget.callback(emoji.key, "", "");

                              // close the drawer
                              if (widget.closeDrawerOnSelect) {
                                Navigator.pop(context);
                              }
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 50,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(emoji.value),
                                  ),
                                ),
                                Expanded(
                                  child: Text(emoji.key),
                                )
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),

              /// If case of empty media
              !imageExist && !emojiExist
                  ? const Text(
                      'No data found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  ImagePainter(this.image);
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) => image != oldDelegate.image;
}
