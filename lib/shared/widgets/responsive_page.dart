import 'package:flutter/material.dart';
import '../../core/utils/keyboard_utils.dart';

/// A simple responsive wrapper that centers content and constrains
/// maximum width for desktop while preserving full-width on mobile.
/// Also handles keyboard dismissal when tapping outside input fields.
class ResponsivePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  /// If true, tapping outside input fields will dismiss the keyboard
  final bool dismissKeyboardOnTap;

  const ResponsivePage({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 1100,
    this.dismissKeyboardOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Widget content;

      // For narrow screens, just use provided padding and full width
      if (constraints.maxWidth < 900) {
        content = Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        );
      } else {
        // For wider screens, center and constrain width and add a subtle background
        content = Center(
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
      }

      // Wrap with gesture detector to dismiss keyboard on tap
      if (dismissKeyboardOnTap) {
        return GestureDetector(
          onTap: () => KeyboardUtils.dismissKeyboard(context),
          behavior: HitTestBehavior.translucent,
          child: content,
        );
      }

      return content;
    });
  }
}
