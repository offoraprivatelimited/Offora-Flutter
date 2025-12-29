import 'package:flutter/material.dart';

/// Wraps the whole app to provide sensible desktop/web layout behaviour.
///
/// - Centers content and constrains maximum width on wide screens.
/// - Applies larger horizontal padding on desktop.
class ResponsiveApp extends StatelessWidget {
  final Widget child;
  const ResponsiveApp({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;

      // Breakpoints
      const desktopBreakpoint = 1000.0;
      const tabletBreakpoint = 600.0;

      if (width >= desktopBreakpoint) {
        // Desktop: center and constrain width for comfortable reading
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: child,
          ),
        );
      } else if (width >= tabletBreakpoint) {
        // Tablet: slightly constrained
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: child,
          ),
        );
      }

      // Mobile: full width, no horizontal padding
      return child;
    });
  }
}
