import 'package:emoji_party/model/media.dart';
import 'package:flutter/material.dart';

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

class _EmojiDrawerState extends State<EmojiDrawer> {
  /// For filtering the emoji drawer
  final TextEditingController _editingController = TextEditingController();

  /// Boolean value to check if search string exist
  bool imageExist = true;
  bool emojiExist = true;

  @override
  void initState() {
    /// Setup the search string if there is one already typed in by the user
    _editingController.text = widget.mediaGenerator.searchString;
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
                          /// for all the available emojis
                          children:
                              widget.mediaGenerator.imagesMatchingSearchString()

                                  /// Make a clickable row
                                  .map(
                            (image) {
                              /// Images name with path details
                              String imageString =
                                  "assets/custom/images/$image.png";

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
                                  widget.callback("", image);

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
                                        child: Image.asset(imageString),
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

                        /// Make a clickable row
                        .map(
                          (emoji) => InkWell(
                            onTap: () {
                              widget.callback(emoji.key, "");

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
