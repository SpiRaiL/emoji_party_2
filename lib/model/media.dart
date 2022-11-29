import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:emoji_party/model/block.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

class Media {
  Color? color;
  String?
      media; // it will specify the media data, asset path for images and emoji data from package for emojis
  String? name;
  bool? animated;
  String? mediaType;

  Media({
    required this.color,
    required this.media,
    required this.name,
    this.animated = false,
    required this.mediaType,
  });

  Media.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    media = json['media'];
    name = json['name'];
    animated = json['animated'];
    mediaType = json['media_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['media'] = media;
    data['name'] = name;
    data['animated'] = animated;
    data['media_type'] = mediaType;
    return data;
  }
}

class MediaGenerator {
  /// List of images from assets
  List<String> imageList = [];

  /// A big list of emojis
  Map<String, dynamic> emojiMap = {};

  MediaGenerator() {
    getImageList();
    buildEmojiMap();
  }

  void getImageList() async {
    /// get all the images from the assets folder

    imageList = ["bubble", "doughnut", "swirl"];
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

  Media getMedia(String name, bool mediaType) {
    final double hue = Random().nextDouble() * 360;
    Color color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    if (mediaType && BlockSet().media.mediaType == "image") {
      return Media(
          color: color,
          media: "assets/custom/images/$name.png",
          name: name,
          mediaType: "image");
    } else if (!mediaType && BlockSet().media.mediaType == "image") {
      return Media(
        color: color,
        media: emojiMap[name],
        name: name,
        mediaType: "emoji",
      );
    } else {
      return Media(
        color: color,
        media: '',
        name: name,
        mediaType: '',
      );
    }
  }

  Media randomMedia(bool mediaType) {
    final double hue = Random().nextDouble() * 360;
    Color color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    if (!mediaType) {
      /// Get a random index from the list.
      int index = Random().nextInt(emojiMap.length);

      // var result = emojiMap.entries[index];
      String emojiName = emojiMap.keys.elementAt(index);
      String emoji = emojiMap[emojiName];

      // String emoji = emojiList[index];
      // String emojiName = emojiNames[index];

      // developer.log("Generated: $emojiName - $emoji", name: "emoji");

      return Media(
          color: color, media: emoji, name: emojiName, mediaType: 'emoji');
    } else {
      /// Get a random index from the list.
      int index = Random().nextInt(imageList.length);

      String name = imageList[index];

      developer.log("Generated: $name - assets/custom/images/$name.png",
          name: "image");

      return Media(
          color: color,
          media: "assets/custom/images/$name.png",
          name: name,
          mediaType: "image");
    }
  }

  String searchString = "";
  List<String> imagesMatchingSearchString() {
    /// Search functionality on the image list
    return imageList.where((image) => image.contains(searchString)).toList();
  }

  Iterable<MapEntry<String, dynamic>> emojisMatchingSearchString() {
    /// Search functionality on the emoji list
    return emojiMap.entries.where((emoji) => emoji.key.contains(searchString));
  }
}
