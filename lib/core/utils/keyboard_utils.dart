import 'package:flutter/material.dart';

/// Utility class for handling keyboard-related operations across the app.
/// Designed specifically to fix Flutter Web mobile keyboard bugs.
class KeyboardUtils {
  /// Dismisses the keyboard by unfocusing all input fields.
  /// Call this when user taps outside of input fields.
  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Returns true if keyboard is likely visible.
  /// Works by checking the view insets.
  static bool isKeyboardVisible(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return viewInsets.bottom > 0;
  }

  /// Get the keyboard height from view insets.
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
}

/// A widget that wraps content and provides keyboard-safe behavior.
///
/// Features:
/// - Dismisses keyboard when tapping outside input fields
/// - Properly handles scroll behavior with keyboard
/// - Prevents layout jumps on keyboard open/close
/// - Optimized for Flutter Web mobile view
class KeyboardSafeArea extends StatelessWidget {
  final Widget child;

  /// If true, the content will be scrollable
  final bool scrollable;

  /// Additional bottom padding when keyboard is visible
  final double extraKeyboardPadding;

  /// If true, tapping outside will dismiss the keyboard
  final bool dismissOnTap;

  /// Optional scroll controller for the internal ScrollView
  final ScrollController? scrollController;

  /// Padding for the content
  final EdgeInsetsGeometry? padding;

  const KeyboardSafeArea({
    super.key,
    required this.child,
    this.scrollable = true,
    this.extraKeyboardPadding = 20.0,
    this.dismissOnTap = true,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Wrap in scrollable container if needed
    if (scrollable) {
      content = SingleChildScrollView(
        controller: scrollController,
        // This ensures scroll view doesn't jump on keyboard open/close
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding: padding,
        child: content,
      );
    } else if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // Wrap with gesture detector to dismiss keyboard on tap
    if (dismissOnTap) {
      content = GestureDetector(
        onTap: () => KeyboardUtils.dismissKeyboard(context),
        behavior: HitTestBehavior.translucent,
        child: content,
      );
    }

    return content;
  }
}

/// A Scaffold wrapper that handles keyboard behavior properly for web.
///
/// This addresses common issues:
/// - Page getting stuck when keyboard opens/closes
/// - Content jumping around
/// - Inability to scroll to see input fields
class KeyboardSafeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Key? scaffoldKey;

  const KeyboardSafeScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => KeyboardUtils.dismissKeyboard(context),
      child: Scaffold(
        key: scaffoldKey,
        appBar: appBar,
        // IMPORTANT: Keep true to allow proper keyboard handling
        // When false, keyboard can obscure input fields
        resizeToAvoidBottomInset: true,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: drawer,
        endDrawer: endDrawer,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}

/// Mixin to add keyboard handling capabilities to StatefulWidgets
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with KeyboardHandlerMixin {
///   @override
///   Widget build(BuildContext context) {
///     return buildWithKeyboardHandler(
///       context,
///       child: YourContent(),
///     );
///   }
/// }
/// ```
mixin KeyboardHandlerMixin<T extends StatefulWidget> on State<T> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// Dismisses the keyboard
  void dismissKeyboard() {
    KeyboardUtils.dismissKeyboard(context);
  }

  /// Wraps a widget with keyboard handling
  Widget buildWithKeyboardHandler(
    BuildContext context, {
    required Widget child,
    bool dismissOnTap = true,
  }) {
    if (!dismissOnTap) return child;

    return GestureDetector(
      onTap: dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// Extension on ScrollController for keyboard-aware scrolling
extension KeyboardAwareScrolling on ScrollController {
  /// Scrolls to make sure a field is visible above the keyboard
  void scrollToShowField({
    required BuildContext context,
    required GlobalKey fieldKey,
    double extraPadding = 100,
  }) {
    final keyboardHeight = KeyboardUtils.getKeyboardHeight(context);
    if (keyboardHeight == 0) return;

    final RenderBox? renderBox =
        fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final fieldBottom = offset.dy + renderBox.size.height;
    final visibleBottom = screenHeight - keyboardHeight;

    if (fieldBottom > visibleBottom) {
      final scrollAmount = fieldBottom - visibleBottom + extraPadding;
      animateTo(
        position.pixels + scrollAmount,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

/// A form field wrapper that ensures visibility when focused
class KeyboardAwareField extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final double extraPadding;

  const KeyboardAwareField({
    super.key,
    required this.child,
    this.focusNode,
    this.scrollController,
    this.extraPadding = 100,
  });

  @override
  State<KeyboardAwareField> createState() => _KeyboardAwareFieldState();
}

class _KeyboardAwareFieldState extends State<KeyboardAwareField> {
  late FocusNode _focusNode;
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.scrollController != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.scrollController!.scrollToShowField(
            context: context,
            fieldKey: _fieldKey,
            extraPadding: widget.extraPadding,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _fieldKey,
      child: widget.child,
    );
  }
}

/// Utility class that provides keyboard-safe bottom padding
/// Useful for screens with fixed bottom elements
class KeyboardBottomPadding extends StatelessWidget {
  final double minPadding;

  const KeyboardBottomPadding({
    super.key,
    this.minPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return SizedBox(
      height: keyboardHeight > 0 ? keyboardHeight + minPadding : minPadding,
    );
  }
}
