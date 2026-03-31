import 'package:flutter/material.dart';

/// Wrapper for displaying info pages inline within MainScreen
/// Provides a back button and proper styling for content area display
class InlineInfoPageWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final VoidCallback onBack;

  const InlineInfoPageWrapper({
    super.key,
    required this.child,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: onBack,
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
