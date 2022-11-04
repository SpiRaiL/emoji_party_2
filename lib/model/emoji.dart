import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'dart:developer' as developer;

class EmojiData {
  Color color;
  String emoji;
  String emojiName;

  EmojiData({
    required this.color,
    required this.emoji,
    required this.emojiName,
  });
}

class EmojiGenerator {
  /// A big list of emojis
  Map<String, dynamic> emojiMap = {};

  EmojiGenerator() {
    buildEmojiMap();
  }

  void buildEmojiMap() {
    /// Pull the emojis out of the huge list of them in the
    /// flutter emoji library.
    /// This function is copied from the _init() function in that library
    /// and simplified to be just a list of strings.
    emojiMap = jsonDecode(EmojiParser.JSON_EMOJI);

    /// Example of a platform check
    /// The flag emojis don't render well on windows 10
    if (defaultTargetPlatform == TargetPlatform.windows) {
      emojiMap.removeWhere((key, value) => key.contains("flag-"));
    }
    developer.log("${emojiMap.length} emojis found", name: "emoji");
  }

  EmojiData getEmoji(String emojiName) {
    final double hue = Random().nextDouble() * 360;
    Color color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    return EmojiData(
        color: color, emoji: emojiMap[emojiName], emojiName: emojiName);
  }

  EmojiData randomEmoji() {
    final double hue = Random().nextDouble() * 360;
    Color color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    /// Get a random index from the list.
    int index = Random().nextInt(emojiMap.length);

    // var result = emojiMap.entries[index];
    String emojiName = emojiMap.keys.elementAt(index);
    String emoji = emojiMap[emojiName];

    // String emoji = emojiList[index];
    // String emojiName = emojiNames[index];

    developer.log("Generated: $emojiName - $emoji", name: "emoji");

    return EmojiData(color: color, emoji: emoji, emojiName: emojiName);
  }
}
