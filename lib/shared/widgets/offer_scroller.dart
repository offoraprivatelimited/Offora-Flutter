import 'package:flutter/material.dart';

class OfferScroller extends StatefulWidget {
  final List<String> texts;
  const OfferScroller({super.key, required this.texts});

  @override
  State<OfferScroller> createState() => _OfferScrollerState();
}

class _OfferScrollerState extends State<OfferScroller>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(_autoScroll);
    _animationController.repeat();
  }

  void _autoScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll == 0) return;
    _scrollPosition += 0.7;
    if (_scrollPosition >= maxScroll) {
      _scrollPosition = 0;
      _scrollController.jumpTo(0);
    } else {
      _scrollController.jumpTo(_scrollPosition);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 24,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: widget.texts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 32),
          itemBuilder: (context, index) => Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.texts[index],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
