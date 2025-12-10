// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

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
    // Use login screen colors
    const loginBlue = Color(0xFF1F477D);
    const onboardingGold = Color(0xFFEAB644); // rgba(234, 182, 68)

    const lightOrange = Color(0xFFFFF4ED);
    const gray20 = Color(0xFFF5F5F5);
    const primaryDark = Color(0xFF1F477D); // Use loginBlue for primaryDark

    final slides = [
      _Slide(
        title: 'Discover Offers',
        subtitle:
            'Find curated deals from brands and premium establishments with our advanced search.',
        accentColor: onboardingGold,
        gradientColors: [onboardingGold, onboardingGold],
        icon: const Icon(Icons.search, size: 72, color: Colors.white),
      ),
      _Slide(
        title: 'Compare & Select',
        subtitle:
            'Side-by-side comparison of exclusive offers with detailed analytics to make informed decisions.',
        accentColor: loginBlue,
        gradientColors: [loginBlue, const Color(0xFF1A3A5A)],
        icon: Stack(
          children: [
            const Icon(Icons.analytics_outlined, size: 72, color: Colors.white),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onboardingGold,
                ),
                child: const Icon(Icons.balance_outlined,
                    size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      _Slide(
        title: 'Save & Notify',
        subtitle:
            'Bookmark luxury deals and receive timely notifications before expiration. Never miss an exclusive offer.',
        accentColor: onboardingGold,
        gradientColors: [onboardingGold, onboardingGold],
        icon: Stack(
          children: [
            const Icon(Icons.bookmark_add_outlined,
                size: 72, color: Colors.white),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: loginBlue,
                ),
                child: const Icon(Icons.notifications_none,
                    size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Professional gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    lightOrange.withOpacity(0.3),
                    Colors.white,
                    lightOrange.withOpacity(0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Decorative orange circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      onboardingGold.withOpacity(0.12),
                      onboardingGold.withOpacity(0.05),
                      Colors.transparent
                    ],
                    stops: const [0, 0.6, 1],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      loginBlue.withOpacity(0.08),
                      loginBlue.withOpacity(0.03),
                      Colors.transparent
                    ],
                    stops: const [0, 0.6, 1],
                  ),
                ),
              ),
            ),

            // Floating geometric shapes
            Positioned(
              right: 40,
              top: MediaQuery.of(context).size.height * 0.25,
              child: Transform.rotate(
                angle: 15 * 3.14159 / 180,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        onboardingGold.withOpacity(0.1),
                        onboardingGold.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: onboardingGold.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 30,
              top: MediaQuery.of(context).size.height * 0.15,
              child: Transform.rotate(
                angle: -20 * 3.14159 / 180,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: onboardingGold.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Premium Logo Header
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: onboardingGold.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo/original/Logo_without_text_without_background.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Offora',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F477D),
                          letterSpacing: -0.8,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [onboardingGold, onboardingGold],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PREMIUM OFFERS',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
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

                // Enhanced Bottom Controls
                Container(
                  margin:
                      const EdgeInsets.only(bottom: 32, left: 24, right: 24),
                  child: Column(
                    children: [
                      // Progress Indicator with step numbers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _page == i ? 40 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _page == i
                                  ? slides[_page].accentColor
                                  : gray20,
                              boxShadow: _page == i
                                  ? [
                                      BoxShadow(
                                        color: slides[_page]
                                            .accentColor
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Enhanced Buttons with elevation and gradients
                      Row(
                        children: [
                          if (_page > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _controller.previousPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                  side: BorderSide(
                                    color: primaryDark.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 16,
                                      color: primaryDark,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Back',
                                      style: TextStyle(
                                        color: primaryDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_page > 0) const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: slides[_page].gradientColors,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: slides[_page]
                                        .accentColor
                                        .withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_page == slides.length - 1) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/role-selection',
                                    );
                                  } else {
                                    _controller.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOutCubic,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _page == slides.length - 1
                                          ? 'Get Started'
                                          : 'Continue',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    if (_page < slides.length - 1)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
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
  final Color accentColor;
  final List<Color> gradientColors;
  final Widget icon;

  const _Slide({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.gradientColors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced Icon Container with floating effect
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    child: Center(child: icon),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title with decorative underline
              Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subtitle with improved typography
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  height: 1.4,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
