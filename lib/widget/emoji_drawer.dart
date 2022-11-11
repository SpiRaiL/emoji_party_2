import 'package:flutter/material.dart';

import '../model/emoji.dart';

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
  const EmojiDrawer(
      {required this.emojiGenerator,
      required this.callback,
      super.key,
      this.closeDrawerOnSelect = true,
      required this.initialSearchString});

  final EmojiGenerator emojiGenerator;
  final Function callback;
  final bool closeDrawerOnSelect;
  final String initialSearchString;

  @override
  State<EmojiDrawer> createState() => _EmojiDrawerState();
}

class _EmojiDrawerState extends State<EmojiDrawer> {
  /// For filtering the emoji drawer
  final TextEditingController _editingController = TextEditingController();
  String searchString = "";

  @override
  void initState() {
    /// Setup the search string if there is one already typed in by the user
    searchString = widget.initialSearchString;
    _editingController.text = searchString;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchString = value;
                });
              },
              controller: _editingController,
              decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView(

                /// for all the available emojis
                children: widget.emojiGenerator.emojiMap.entries
                    // Filter by the query text
                    .where((emoji) => emoji.key.contains(searchString))

                    /// Make a clickable row
                    .map((emoji) => InkWell(
                          onTap: () {
                            widget.callback(emoji.key, searchString);

                            // close the drawer
                            if (widget.closeDrawerOnSelect) {
                              Navigator.pop(context);
                            }
                          },
                          child: Row(children: [
                            SizedBox(
                                width: 100,
                                height: 50,
                                child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(emoji.value))),
                            Expanded(child: Text(emoji.key))
                          ]),
                        ))
                    .toList()),
          ),
        ],
      ),
    ));
  }
}
