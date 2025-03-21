import 'package:flutter/material.dart';

class FadeOut extends StatelessWidget {
  final Widget child;
  final double fadeStart;
  final double fadeEnd;
  final Color color;

  const FadeOut({
    super.key,
    required this.child,
    required this.color,
    this.fadeStart = 0.93,
    this.fadeEnd = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned.fill(
          child: IgnorePointer(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, color],
                  stops: [fadeStart, fadeEnd],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }
}