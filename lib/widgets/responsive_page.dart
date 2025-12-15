import 'package:flutter/material.dart';

/// A simple responsive wrapper that centers content and constrains
/// maximum width for desktop while preserving full-width on mobile.
class ResponsivePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  const ResponsivePage(
      {super.key, required this.child, this.padding, this.maxWidth = 1100});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // For narrow screens, just use provided padding and full width
      if (constraints.maxWidth < 900) {
        return Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        );
      }

      // For wider screens, center and constrain width and add a subtle background
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ),
      );
    });
  }
}
