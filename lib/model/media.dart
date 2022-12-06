import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

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
  /// Asset media list [png and gif images from assets]
  List<Map<String, String>> imageList = [];

  /// List of media names
  List<String> imageName = [];

  /// A big list of emojis
  Map<String, dynamic> emojiMap = {};

  /// GetX controller

  MediaGenerator() {
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

  Media changeMedia(String name, String path, bool isImage) {
    final double hue = Random().nextDouble() * 360;
    Color color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    /// if clicked on image to replace block
    if (isImage) {
      return Media(
        color: color,
        media: path,
        name: name,
        mediaType: "image",
      );
    }

    /// if clicked on emoji to replace block
    else {
      return Media(
        color: color,
        media: emojiMap[name],
        name: name,
        mediaType: "emoji",
      );
    }
  }

  Media randomMedia(bool isImage) {
    final double hue = Random().nextDouble() * 360;
    Color color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    if (!isImage) {
      /// Get a random index from the list.
      int index = Random().nextInt(emojiMap.length);

      String emojiName = emojiMap.keys.elementAt(index);
      String emoji = emojiMap[emojiName];

      return Media(
        color: color,
        media: emoji,
        name: emojiName,
        mediaType: 'emoji',
      );
    } else {
      /// Get a random index from the list.
      int index = Random().nextInt(imageList.length);

      String? name = imageList[index]["name"];
      String? path = imageList[index]["path"];

      developer.log("Generated: $name - $path", name: "image");

      return Media(
        color: color,
        media: path,
        name: name,
        mediaType: "image",
      );
    }
  }

  String searchString = "";
  List<String> imagesMatchingSearchString() {
    /// Search functionality on the image list
    return imageName
        .toSet()
        .where((image) => image.contains(searchString))
        .toList();
  }

  Iterable<MapEntry<String, dynamic>> emojisMatchingSearchString() {
    /// Search functionality on the emoji list
    return emojiMap.entries.where((emoji) => emoji.key.contains(searchString));
  }
}
