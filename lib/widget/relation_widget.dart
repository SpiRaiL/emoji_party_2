import 'dart:math';
import 'package:flutter/material.dart';

import '../model/block.dart';

class RelationWidget extends StatelessWidget {
  const RelationWidget({required this.relation, super.key});

  final BlockRelation relation;

  @override
  Widget build(BuildContext context) {
    /// Get the bounds of the curve
    final directions = relation.thisBlock.getClosestEdges(relation.thatBlock);

    Offset thisBlockEdge = relation.thisBlock.edgeCenter(directions[0]);
    Offset thatBlockEdge = relation.thatBlock.edgeCenter(directions[1]);

    /// Calculate the box that this path will be drawn in
    double left = min(thisBlockEdge.dx, thatBlockEdge.dx);
    double top = min(thisBlockEdge.dy, thatBlockEdge.dy);
    double width = max(thisBlockEdge.dx, thatBlockEdge.dx) - left;
    double height = max(thisBlockEdge.dy, thatBlockEdge.dy) - top;

    /// Create the offsets for the points along the path
    /// [influence] is 0->1 the scaling factor on the curve.
    /// 1 is a tight corner
    /// 0 is a straight line
    /// 0.5 is a nice quadratic look
    /// [influenceMinimum] is minimum number of pixes the curve can be.
    /// Stops sharp edges when the distance is very short
    const double influence = 0.5;
    const double influenceMinimum = 30;
    List<Offset> offsets = [];
    Offset start = Offset(thisBlockEdge.dx - left, thisBlockEdge.dy - top);
    offsets.add(start);
    switch (directions[0]) {
      case AxisDirection.up:
        offsets
            .add(start + Offset(0, -max(height * influence, influenceMinimum)));
        break;
      case AxisDirection.down:
        offsets
            .add(start + Offset(0, max(height * influence, influenceMinimum)));
        break;
      case AxisDirection.left:
        offsets
            .add(start + Offset(-max(width * influence, influenceMinimum), 0));
        break;
      case AxisDirection.right:
        offsets
            .add(start + Offset(max(width * influence, influenceMinimum), 0));
        break;
      default:
        offsets.add(start);
        break;
    }

    Offset end = Offset(thatBlockEdge.dx - left, thatBlockEdge.dy - top);
    switch (directions[1]) {
      case AxisDirection.up:
        offsets
            .add(end + Offset(0, -max(height * influence, influenceMinimum)));
        break;
      case AxisDirection.down:
        offsets.add(end + Offset(0, max(height * influence, influenceMinimum)));
        break;
      case AxisDirection.left:
        offsets.add(end + Offset(-max(width * influence, influenceMinimum), 0));
        break;
      case AxisDirection.right:
        offsets.add(end + Offset(max(width * influence, influenceMinimum), 0));
        break;
      default:
        offsets.add(end);
        break;
    }

    offsets.add(end);

    return Positioned(
        left: left,
        top: top,
        child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                border: Border.all(
                    color: relation.thisBlock.blockSet.experimental
                        ? Colors.amber
                        : Colors.transparent)),
            child:
                CustomPaint(foregroundPainter: PathPainter(offsets: offsets))));
  }
}

class PathPainter extends CustomPainter {
  PathPainter({required this.offsets});

  final List<Offset> offsets;

  /// The painter that places the line in its bound canvas
  @override
  void paint(Canvas canvas, Size size) {
    // final double hue = Random().nextDouble() * 360;
    // Color color = HSLColor.fromAHSL(1, hue, 1, 0.85).toColor();

    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Offset arrowA = offsets[3];
    double endDir = (offsets[3] - offsets[2]).direction;
    const double arrowSize = 20;

    Offset arrowB = Offset.fromDirection(endDir - 0.30, -arrowSize) + arrowA;
    Offset arrowC = Offset.fromDirection(endDir + 0.30, -arrowSize) + arrowA;
    Offset endInf = offsets[2] - Offset.fromDirection(endDir, arrowSize);
    Offset end = arrowA - Offset.fromDirection(endDir, arrowSize);

    /// Straight line for symmetry
    double startDir = (offsets[0] - offsets[1]).direction;
    Offset start = offsets[0] - Offset.fromDirection(startDir, arrowSize);
    Offset startInf = offsets[1] - Offset.fromDirection(startDir, arrowSize);

    final path = Path()
      ..moveTo(offsets[0].dx, offsets[0].dy)
      ..lineTo(start.dx, start.dy)
      ..cubicTo(startInf.dx, startInf.dy, endInf.dx, endInf.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);

    final arrow = Path()
      ..moveTo(arrowC.dx, arrowC.dy)
      ..lineTo(arrowA.dx, arrowA.dy)
      ..lineTo(arrowB.dx, arrowB.dy);

    paint.style = PaintingStyle.fill;

    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
