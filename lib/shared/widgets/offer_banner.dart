import 'package:flutter/material.dart';

class OfferBanner extends StatefulWidget {
  const OfferBanner({
    super.key,
    required this.imageUrls,
    this.onTap,
    this.height = 180,
  });

  final List<String> imageUrls;
  final VoidCallback? onTap;
  final double height;

  @override
  State<OfferBanner> createState() => _OfferBannerState();
}

class _OfferBannerState extends State<OfferBanner>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  late AnimationController _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _autoSlideTimer.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentIndex < widget.imageUrls.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(0);
        }
        _autoSlideTimer.forward(from: 0.0);
      }
    });

    _autoSlideTimer.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer.dispose();
    super.dispose();
  }

  void _resetAutoSlide() {
    _autoSlideTimer.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Make banner slightly smaller on mobile view
    double bannerHeight = widget.height;
    if (screenWidth < 600) {
      bannerHeight =
          widget.height * 0.75; // 75% of default height on mobile (135px)
    }

    if (widget.imageUrls.isEmpty) {
      return Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: const Center(
          child: Text('No banners available'),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _resetAutoSlide();
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Dots indicator
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          _resetAutoSlide();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
