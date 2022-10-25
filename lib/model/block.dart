// A specific model class for just block data.
// No widget building data

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

/// A big list of emojis
List<String> _emojiList = [];
List<String> _emojiNames = [];

void buildEmojiMap() {
  /// Pull the emojis out of the huge list of them in the
  /// flutter emoji library.
  /// This function is copied from the _init() function in that library
  /// and simplified to be just a list of strings.
  Map<String, dynamic> mapEmojis = jsonDecode(EmojiParser.JSON_EMOJI);
  mapEmojis.forEach((key, value) {
    /// Example of a platform check
    /// The flag emojis don't render well on windows 10
    if (!(defaultTargetPlatform == TargetPlatform.windows &&
        key.contains("flag-"))) {
      _emojiNames.add(key);
      _emojiList.add(value);
    }
  });
}

class Block {
  /// Block class
  ///
  /// This houses just the data of what is in each block,
  /// and the method of generating the data.
  /// You can set a color and a name (some text to appear on the page)
  /// or you can generate some random data to play with

  Color color;
  String displayName;
  String details;
  bool selected = false;

  Block(
      {this.color = Colors.white,
      this.displayName = "None",
      this.details = "None",
      generate = false,
      emoji = false}) {
    if (generate) {
      generateData(emoji: emoji);
    }
  }

  generateData({emoji = false}) {
    /// Is its own function so that it can be called
    /// by the app-bar buttons
    var random = Random();
    final double hue = random.nextDouble() * 360;
    color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    if (emoji) {
      /// Pick from some random range of unicode values
      /// check for an emoji or try again.
      /// clearly could be better

      ///  Generate the emoji list if we need it (one time)
      if (_emojiList.isEmpty) {
        buildEmojiMap();
      }

      /// Get a random index from the list.
      int index = Random().nextInt(_emojiList.length);
      displayName = _emojiList[index];
      details = _emojiNames[index];
    } else {
      /// Just some random text instead
      var random = Random();

      /// Make a random 3 char string
      const String chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      const int length = 3;
      displayName = String.fromCharCodes(Iterable.generate(
          length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    }
  }
}
