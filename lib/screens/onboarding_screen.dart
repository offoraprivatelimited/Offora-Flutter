import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);
    const darkerGold = Color(0xFFA3834D);

    final slides = [
      const _Slide(
        title: 'Discover',
        subtitle: 'Explore amazing offers from your favorite local businesses.',
        icon: Icons.compass_calibration_outlined,
        accentColor: brightGold,
      ),
      const _Slide(
        title: 'Compare',
        subtitle: 'Compare deals side-by-side and always get the best price.',
        icon: Icons.compare_arrows_outlined,
        accentColor: darkBlue,
      ),
      const _Slide(
        title: 'Save',
        subtitle: 'Save your favorites and get notified before they expire.',
        icon: Icons.bookmark_outline,
        accentColor: brightGold,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradients
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      brightGold.withOpacity(0.8),
                      brightGold.withOpacity(0.2)
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      darkBlue.withOpacity(0.7),
                      darkBlue.withOpacity(0.1)
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Header with Offora logo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: darkerGold.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'images/logo/original/Logo_without_text_without_background.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Offora',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => slides[i],
                  ),
                ),
                // Dots and Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (i) => Container(
                            width: _page == i ? 28 : 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: _page == i
                                  ? slides[_page].accentColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Buttons
                      Row(
                        children: [
                          if (_page > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _controller.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(
                                    color: darkBlue,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          if (_page > 0) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_page == slides.length - 1) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/role-selection',
                                  );
                                } else {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: slides[_page].accentColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                _page == slides.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _Slide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor,
                  accentColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 36),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
