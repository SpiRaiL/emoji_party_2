// A specific model class for just block data.
// No widget building data

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

class BlockSet {
  /// A class for all the relevant block data as a full group
  List<Block> allBlocks = [];
  List<Block> selectedBlocks = [];

  /// [setStateCallback] is currently needed for dragging a selected group
  /// This is because setState at this level is only able to rerender the
  /// widget being dragged.
  Function setStateCallback;

  BlockSet({required this.setStateCallback}) {
    addBlock();
  }

  void addBlock() {
    /// Add a block to the list of blocks
    allBlocks.add(Block(generate: true, emoji: true, blockSet: this));
  }

  void deleteSelected() {
    // delete the selected blocks
    allBlocks.removeWhere((block) => selectedBlocks.contains(block));
    selectedBlocks.clear();
  }

  void selectAllOrNone() {
    /// If they are all selected
    if (selectedBlocks.length == allBlocks.length) {
      /// Select None
      selectedBlocks.clear();
    } else {
      /// Select all
      selectedBlocks.clear();
      selectedBlocks.addAll(allBlocks);
    }
  }

  List<Block> selectedInOrder() {
    /// Get the selected order based on where the block is in allBlocks
    /// ie: since selected blocks is ordered based when the user clicks on it
    List<Block> selection = [];
    for (Block block in allBlocks) {
      if (selectedBlocks.contains(block)) {
        selection.add(block);
      }
    }
    return selection;
  }

  bool _areAllSelected({onTop = false, onBottom = false}) {
    /// Returns true if the selected items are already on top of the stack
    bool itemBeforeSelected = false;
    bool itemAfterSelected = false;
    bool selectedFound = false;

    for (Block block in allBlocks) {
      if (selectedBlocks.contains(block)) {
        selectedFound = true;
      } else {
        if (!selectedFound) {
          itemBeforeSelected = true;
        } else {
          itemAfterSelected = true;
        }
      }
    }
    if (onTop && itemAfterSelected) {
      return false;
    }
    if (onBottom && itemBeforeSelected) {
      return false;
    }
    return true;
  }

  void toTop({preserveOrder = true, exceptWhenOnTop = true}) {
    /// Move selected items to the top of the stack
    /// ie: the end of the list
    /// Using [preserveOrder] keeps the order of the blocks intact
    /// [exceptWhenOnTop] breaks the preservation if they are already on top
    /// And falls back to the selected order "first clicked is on top"

    if (exceptWhenOnTop && _areAllSelected(onTop: true)) {
      preserveOrder = false;
    }

    List<Block> selection =
        preserveOrder ? selectedInOrder() : selectedBlocks.reversed.toList();

    /// Place blocks on the top based on their order in the selection
    /// Last block is the top block
    for (Block block in selection) {
      int index = allBlocks.indexOf(block);
      allBlocks.insert(allBlocks.length - 1, allBlocks.removeAt(index));
    }
  }

  void toBottom({preserveOrder = true, exceptWhenOnBottom = true}) {
    /// Move selected items to the bottom of the stack
    /// ie: the start of the list
    /// Using [preserveOrder] keeps the order of the blocks intact
    /// [exceptWhenOnBottom] breaks the preservation if they are already on top
    /// And falls back to the selected order
    /// The default is false, which means the new order is based on
    /// And falls back to the selected order "first clicked is on bottom"

    if (exceptWhenOnBottom && _areAllSelected(onBottom: true)) {
      preserveOrder = false;
    }

    List<Block> selection = preserveOrder ? selectedInOrder() : selectedBlocks;

    for (Block block in selection.reversed) {
      int index = allBlocks.indexOf(block);
      allBlocks.insert(0, allBlocks.removeAt(index));
    }
  }

  void reGenerate() {
    /// Re-roll the emoji, in the same place in the stack
    for (Block block in selectedBlocks) {
      block.generateData(emoji: true);
    }
  }

  ///
  /// Selection functions
  ///
  bool selectBlock(Block block, bool trueFalse) {
    /// Selects the [block] based on [trueFalse]
    /// Returns true on success
    /// False if already added or removed
    if (trueFalse) {
      if (!selectedBlocks.contains(block)) {
        selectedBlocks.add(block);
        return true;
      }
    } else {
      if (selectedBlocks.contains(block)) {
        selectedBlocks.remove(block);
        return true;
      }
    }
    return false;
  }

  bool toggleSelectBlock(Block block) {
    /// Toggles if the block is part of selected blocks
    /// [returns] if the block is selected
    if (selectedBlocks.contains(block)) {
      selectedBlocks.remove(block);
      return false;
    } else {
      selectedBlocks.add(block);
      return true;
    }
  }

  bool isBlockSelected(Block block) {
    return selectedBlocks.contains(block);
  }
}

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

  /// Offset is the position of the block.
  /// It needs to be store in the data as it needs to be accessible
  /// by multiple widgets when grouping
  Offset offset = Offset.zero;
  Size size = const Size(100, 100);

  /// A reference to the block set where this blocks belongs is required to
  /// be able to make changes on other blocks
  /// for example blocks in a selected group
  final BlockSet blockSet;

  Block(
      {this.color = Colors.white,
      this.displayName = "None",
      this.details = "None",
      generate = false,
      emoji = false,
      required this.blockSet}) {
    if (generate) {
      generateData(emoji: emoji);
    }
  }

  bool isSelected() {
    return blockSet.isBlockSelected(this);
  }

  void select(bool trueFalse) {
    blockSet.selectBlock(this, trueFalse);
  }

  void toggleSelect() {
    blockSet.toggleSelectBlock(this);
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
