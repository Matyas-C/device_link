import 'package:device_link/ui/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class GradientBorderedInk extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final double borderWidth;
  final double opacity;

  const GradientBorderedInk({
    super.key,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.opacity,
    required this.child,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Ink(
        padding: padding,
        decoration: BoxDecoration(
          color: raisedColor,
          borderRadius: borderRadius,
          border: GradientBoxBorder(
            gradient: LinearGradient(
              colors: [tertiaryColor.withOpacity(opacity), raisedColor],
              begin: gradientBegin,
              end: gradientEnd,
            ),
            width: borderWidth,
          ),
        ),
        child: child,
      ),
    );
  }
}