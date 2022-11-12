// A specific model class for just block data.
// No widget building data

import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'emoji.dart';

class Block {
  /// Block class
  ///
  /// This houses just the data of what is in each block,
  /// and the method of generating the data.
  /// You can set a color and a name (some text to appear on the page)
  /// or you can generate some random data to play with
  EmojiData emoji;

  /// Offset is the position of the block.
  /// It needs to be store in the data as it needs to be accessible
  /// by multiple widgets when grouping
  Offset offset = Offset.zero;
  Size size = const Size(100, 100);

  /// Experimental
  double rotation = 0;

  // The height of the block. How many blocks are under this block
  int blockHeight = 0;

  /// A reference to the block set where this blocks belongs is required to
  /// be able to make changes on other blocks
  /// for example blocks in a selected group
  final BlockSet blockSet;

  Block({required this.emoji, required this.blockSet});

  bool isSelected() {
    return blockSet.isBlockSelected(this);
  }

  void select(bool trueFalse) {
    blockSet.selectBlock(this, trueFalse);
  }

  void toggleSelect() {
    blockSet.toggleSelectBlock(this);
  }

  Offset edgeCenter(AxisDirection direction) {
    /// Get the coordinate of the center of the blocks edge in the
    /// given direction
    switch (direction) {
      case AxisDirection.up:
        return Offset(offset.dx + size.width / 2, offset.dy);
      case AxisDirection.down:
        return Offset(offset.dx + size.width / 2, offset.dy + size.height);
      case AxisDirection.left:
        return Offset(offset.dx, offset.dy + size.height / 2);
      case AxisDirection.right:
        return Offset(offset.dx + size.width, offset.dy + size.height / 2);
      default:
        return const Offset(0, 0);
    }
  }

  List<AxisDirection> getClosestEdges(Block block) {
    // Get the closest edges between two blocks
    List<AxisDirection> allDirections = [
      AxisDirection.up,
      AxisDirection.down,
      AxisDirection.left,
      AxisDirection.right
    ];

    double distance = double.infinity;

    List<AxisDirection> edges = [];

    for (AxisDirection dirA in allDirections) {
      for (AxisDirection dirB in allDirections) {
        double newDistance =
            (edgeCenter(dirA) - block.edgeCenter(dirB)).distance;

        /// Slightly favour right over left
        /// this only applies when blocks are exactly the same size
        if ([dirA, dirB].contains(AxisDirection.right)) {
          newDistance -= 0.001;
        }
        if (newDistance < distance) {
          distance = newDistance;
          edges = [dirA, dirB];
        }
      }
    }
    return edges;
  }
}

class BlockRelation {
  /// A block relation defines how two blocks are connected to each other

  Block thisBlock;
  BlockRelationType type;
  Block thatBlock;

  BlockRelation(this.thisBlock, this.type, this.thatBlock);
}

enum BlockRelationType { hasBlockChild, hasReceiver }

class BlockSet {
  /// A class for all the relevant block data as a full group
  List<Block> allBlocks = [];
  List<Block> selectedBlocks = [];
  List<BlockRelation> relations = [];

  /// Extra functionality and details about the block
  bool experimental = false;

  final EmojiGenerator emojiGenerator = EmojiGenerator();

  /// Scaffold key is needed in the block set to allow
  /// access to the scaffold. Specifically here for opening the emoji drawer
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// When the block set does something that requires a widget rebuild
  /// It also calls this function.
  /// This is where you would put your setState function for the widget
  /// that houses all the blocks
  /// see the block_area lib
  Function? onUpdate;

  BlockSet({this.onUpdate}) {
    addBlock();
  }

  void updateCallback({Block? block}) {
    /// Allows additional logic to happen before the callback executes
    /// updates to the layout
    /// [block] is the block that made this call
    onUpdate?.call();
  }

  bool blockIsInside(Block a, Block b) {
    /// Check if one blocks position is inside another
    if (a.offset.dx > b.offset.dx &&
        a.offset.dx + a.size.width < b.offset.dx + b.size.width &&
        a.offset.dy > b.offset.dy &&
        a.offset.dy + a.size.height < b.offset.dy + b.size.height) {
      return true;
    }
    // developer.log('outside', name: "test");
    return false;
  }

  void piggyBackSort(Block block, {bool update = false}) {
    /// Cycle all blocks and work how who overlaps who
    /// [block] focuses on the block that is changed
    /// [update] calls the updateCallBack function. Default = false

    /// Scroll down form the "top" and place this block above any
    /// that surround it
    for (int index = allBlocks.length - 1;
        index > allBlocks.indexOf(block);
        index--) {
      if (blockIsInside(block, allBlocks[index])) {
        if (experimental) {
          developer.log(
              '${block.emoji.emoji} 🔼 ${allBlocks[index].emoji.emoji}',
              name: "piggyBack");
        }

        /// Drop the block from where it is
        allBlocks.remove(block);

        /// Since the block we are putting on top of already slips down
        /// from the removal action, we can just insert at this point.
        allBlocks.insert(index, block);
        break;
      }
    }

    /// Now go up from the bottom to see if we went under anything smaller
    for (int index = 0; index < allBlocks.indexOf(block); index++) {
      if (blockIsInside(allBlocks[index], block)) {
        if (experimental) {
          developer.log(
              '${block.emoji.emoji} 🔽 ${allBlocks[index].emoji.emoji}',
              name: "piggyBack");
        }
        allBlocks.remove(block);
        allBlocks.insert(index, block);
        break;
      }
    }

    calculateBlockHeights();

    if (update) {
      block.blockSet.updateCallback(block: block);
    }
  }

  void calculateBlockHeights() {
    /// Does what it says.
    ///
    /// Goes through all blocks form bottom to top and works out who
    /// sits on top of who

    /// For all blocks from the bottom up.
    for (int i = 0; i < allBlocks.length; i++) {
      Block a = allBlocks[i];
      a.blockHeight = 0;
      _disownParents(a);

      if (i == 0) {
        // Nothing under the bottom one
        continue;
      }

      /// For all blocks from this block down
      /// Find the highest block that intersects
      /// Where highest is "has the most blocks under"
      /// Not, the "highest index"
      /// with block a.
      for (int j = i - 1; j >= 0; j--) {
        Block b = allBlocks[j];
        // developer.log("compare ${i.toString()} to ${j.toString()}");
        if (blocksIntersect(a, b)) {
          if (b.blockHeight >= a.blockHeight) {
            /// If b is equal higher than a.
            /// we are moving a up, so we need to cut all its parent relations
            _disownParents(a);
          }
          if (b.blockHeight >= a.blockHeight - 1) {
            /// Then (or if its another block one lower)
            /// we add the relationship form a to b.
            relations.add(BlockRelation(b, BlockRelationType.hasBlockChild, a));
            a.blockHeight = b.blockHeight + 1;
          }
        }
      }
    }
  }

  void _disownParents(Block block) {
    /// relations go "this has child of that"
    relations.removeWhere((element) => (element.thatBlock == block &&
        element.type == BlockRelationType.hasBlockChild));
  }

  bool blocksIntersect(Block a, Block b) {
    /// From google  "intersection of 2 rectangles"
    /// This would find the actual area of intersection.
    ///
    // double xOverlap = max(
    //     0,
    //     min(a.offset.dx + a.size.width, b.offset.dx + b.size.width) -
    //         max(a.offset.dx, b.offset.dx));
    // double yOverlap = max(
    //     0,
    //     min(a.offset.dy + a.size.height, b.offset.dy + b.size.height) -
    //         max(a.offset.dy, b.offset.dy));
    // double intersection = xOverlap * yOverlap;

    /// We only care about "if" there is intersection
    /// So this simplifies to:

    if (min(a.offset.dx + a.size.width, b.offset.dx + b.size.width) <=
        max(a.offset.dx, b.offset.dx)) {
      // The left most right side is less than the right-most left side
      return false;
    }

    if (min(a.offset.dy + a.size.height, b.offset.dy + b.size.height) <=
        max(a.offset.dy, b.offset.dy)) {
      // The highest bottom side is higher than the lowest top size
      return false;
    }

    if (experimental) {
      developer.log(
          '${a.emoji.emoji}'
          '(${a.offset.dx}, ${a.offset.dx + a.size.width})'
          '(${a.offset.dy}, ${a.offset.dy + a.size.height})'
          ' intersects '
          '${b.emoji.emoji}'
          '(${b.offset.dx}, ${b.offset.dx + b.size.width})'
          '(${b.offset.dy}, ${b.offset.dy + b.size.height})',
          name: "piggyBack");
    }
    return true;
  }

  void addBlock() {
    /// Add a block to the list of blocks
    allBlocks.add(Block(emoji: emojiGenerator.randomEmoji(), blockSet: this));
    updateCallback();
  }

  void deleteSelected() {
    // delete the selected blocks from the main list
    allBlocks.removeWhere((block) => selectedBlocks.contains(block));
    // delete all their associated relations as well
    relations.removeWhere((relation) =>
        selectedBlocks.contains(relation.thisBlock) ||
        selectedBlocks.contains(relation.thisBlock));
    selectedBlocks.clear();
    updateCallback();
  }

  void selectAllOrNone() {
    /// Clears the selection
    /// Selects all if already cleared
    if (selectedBlocks.isEmpty) {
      selectedBlocks.addAll(allBlocks);
    } else {
      selectedBlocks.clear();
    }
    updateCallback();
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
      piggyBackSort(block);
    }
    updateCallback();
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
      piggyBackSort(block);
    }
    updateCallback();
  }

  void randomEmoji() {
    /// Re-roll the emoji, in the same place in the stack
    for (Block block in selectedBlocks) {
      block.emoji = emojiGenerator.randomEmoji();
    }
    updateCallback();
  }

  void changeEmoji(String emojiName) {
    /// Sets the emoji to the one matching the name
    for (Block block in selectedBlocks) {
      block.emoji = emojiGenerator.getEmoji(emojiName);
    }
    updateCallback();
  }

  void animateEmoji() {
    /// Get the animation state of the first emoji
    bool isAnimated = selectedBlocks.first.emoji.animated;

    for (Block block in selectedBlocks) {
      /// apply the opposite of that state to all selected.
      block.emoji.animated = !isAnimated;
    }
    updateCallback();
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
    bool selected = selectedBlocks.contains(block);
    if (selected) {
      _selectBlockAndChildren(block, false);
    } else {
      _selectBlockAndChildren(block, true);
    }
    updateCallback(block: block);

    return !selected; // flip selected
  }

  void _selectBlockAndChildren(Block block, bool select) {
    /// Add and remove if necessary
    if (select && !selectedBlocks.contains(block)) {
      selectedBlocks.add(block);
    }
    if (!select && selectedBlocks.contains(block)) {
      selectedBlocks.remove(block);
    }

    /// Iterate the relationships to select the child blocks as well.
    for (BlockRelation relation in relations.where((relation) =>
        relation.thisBlock == block &&
        relation.type == BlockRelationType.hasBlockChild)) {
      _selectBlockAndChildren(relation.thatBlock, select);
    }
  }

  bool isBlockSelected(Block block) {
    return selectedBlocks.contains(block);
  }

  void linkForward() {
    /// If 2 blocks are selected this will create a link between them
    /// the link is one way. So the selection order is important
    if (selectedBlocks.length < 2) {
      return;
    }

    for (int i = 1; i < selectedBlocks.length; i++) {
      /// Adds a link relationship between 2 selected blocks
      linkTwoBlocks(selectedBlocks[0], selectedBlocks[i]);
    }
    updateCallback();
  }

  void linkReverse() {
    /// If 2 blocks are selected this will create a link between them
    /// the link is one way. So the selection order is important
    if (selectedBlocks.length < 2) {
      return;
    }

    for (int i = 1; i < selectedBlocks.length; i++) {
      /// Adds a link relationship between 2 selected blocks
      linkTwoBlocks(selectedBlocks[i], selectedBlocks[0]);
    }
    updateCallback();
  }

  void linkTwoBlocks(Block a, Block b) {
    Iterable<BlockRelation> matching = relations.where((r) =>
        r.thisBlock == a &&
        r.type == BlockRelationType.hasReceiver &&
        r.thatBlock == b);

    if (matching.isEmpty) {
      developer.log("linking ${a.emoji.emoji} to ${b.emoji.emoji}");
      relations.add(BlockRelation(a, BlockRelationType.hasReceiver, b));
    } else {
      developer.log("unlinking ${a.emoji.emoji} to ${b.emoji.emoji}");
      relations.removeWhere((link) => matching.contains(link));
    }
  }

  bool blocksAreLinked({bool forward = true}) {
    if (selectedBlocks.length < 2) {
      developer.log("more than 2 selected!");
      return false;
    }
    Block a = selectedBlocks[forward ? 0 : 1];
    Block b = selectedBlocks[forward ? 1 : 0];
    return relations.any((r) =>
        r.thisBlock == a &&
        r.type == BlockRelationType.hasReceiver &&
        r.thatBlock == b);
  }
}
