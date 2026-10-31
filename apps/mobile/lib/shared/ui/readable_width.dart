import 'package:flutter/widgets.dart';

class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.maxWidth, required this.child});

  static const form = 560.0;
  static const list = 720.0;
  static const deck = 512.0;
  static const grid = 1200.0;

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
