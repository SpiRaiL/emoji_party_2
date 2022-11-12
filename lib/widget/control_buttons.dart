import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  /// Icon's that appear in and around the main block area
  const ControlButton({
    Key? key,
    this.icon,
    this.function,
    this.tooltip,
  }) : super(key: key);

  final IconData? icon;
  final void Function()? function;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: function,
      icon: Tooltip(
        message: tooltip,
        child: Icon(
          icon,
        ),
      ),
    );
  }
}
