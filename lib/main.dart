import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/offer_details_screen.dart';

void main() {
  runApp(const OfforaApp());
}

class OfforaApp extends StatelessWidget {
  const OfforaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        AuthScreen.routeName: (_) => const AuthScreen(),
        MainScreen.routeName: (_) => const MainScreen(),
        OfferDetailsScreen.routeName: (_) => const OfferDetailsScreen(),
      },
    );
  }
}

// --- Helpers ---
Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // ignore errors for UI-only demo
  }
}

// --- 1. Hero Section Widget ---
class HeroSection extends StatelessWidget {
  final bool isDesktop;
  const HeroSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600 && size.width <= 1024;
    final double titleSize = isDesktop ? 100 : (isTablet ? 84 : 56);
    final double subTitleSize = isDesktop ? 24 : (isTablet ? 20 : 18);
    final double bodySize = isDesktop ? 16 : (isTablet ? 15 : 14);
    final double comingSoonSize = isDesktop ? 56 : (isTablet ? 44 : 34);
    final double sectionHeight = isDesktop ? size.height : size.height * 0.9;
    final double maxWidth = isDesktop ? 1100 : (isTablet ? 900 : 800);
    return SizedBox(
      height: sectionHeight,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Offora',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha((0.3 * 255).round()),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      Shadow(
                        color: const Color(
                          0xFF4A1BBF,
                        ).withAlpha((0.5 * 255).round()),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover the Best Offers from Every Store — All in One Place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: subTitleSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha((0.5 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      Shadow(
                        color: Colors.black.withAlpha((0.3 * 255).round()),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Offora helps you explore live discounts and deals from clothing, groceries, electronics, restaurants, and every type of store near you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.85 * 255).round()),
                    fontSize: bodySize,
                    height: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SubtleGlowText(
                  text: 'Coming Soon',
                  fontSize: comingSoonSize,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFE9B0),
                      Color(0xFFFFD700),
                      Color(0xFFFF8C00),
                      Color(0xFFFFD700),
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                const SizedBox(height: 36),
                const SocialMediaIconsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Notify Me Input Field and Button ---
class NotifyMeForm extends StatelessWidget {
  final bool isDesktop;
  const NotifyMeForm({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool stackVertical = width < 420;
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
      child: stackVertical
          ? Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your email for early access...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(label: 'Notify Me', onPressed: () {}),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your email for early access...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GradientButton(label: 'Notify Me', onPressed: () {}),
              ],
            ),
    );
  }
}

// --- Social Media Icons Row ---
class SocialMediaIconsRow extends StatelessWidget {
  const SocialMediaIconsRow({super.key});

  @override
  Widget build(BuildContext context) {
    const shareUrl = 'https://legendaryone.in';
    const shareText =
        'Check out Offora — Discover the best offers from every store!';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialIcon(
          icon: Icons.facebook,
          onTap: () {
            _launchUrl(
              'https://www.facebook.com/sharer/sharer.php?u=$shareUrl',
            );
          },
        ),
        SocialIcon(
          icon: Icons.alternate_email, // X/Twitter placeholder
          onTap: () {
            final url = Uri.encodeComponent(shareUrl);
            final text = Uri.encodeComponent(shareText);
            _launchUrl('https://twitter.com/intent/tweet?text=$text&url=$url');
          },
        ),
        SocialIcon(
          icon: Icons.business, // LinkedIn placeholder
          onTap: () {
            _launchUrl(
              'https://www.linkedin.com/sharing/share-offsite/?url=$shareUrl',
            );
          },
        ),
        SocialIcon(
          icon: Icons.chat, // WhatsApp placeholder
          onTap: () {
            final msg = Uri.encodeComponent('$shareText $shareUrl');
            _launchUrl('https://wa.me/?text=$msg');
          },
        ),
      ],
    );
  }
}

// --- 2. About / Highlights Section ---
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;
    bool isTablet = width >= 600 && width <= 1024;
    final double headingSize = isMobile ? 28 : (isTablet ? 32 : 40);
    final double bodySize = isMobile ? 15 : (isTablet ? 16 : 18);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'What is Offora?',
              style: TextStyle(
                color: Colors.white,
                fontSize: headingSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Offora is your all-in-one destination to find, compare, and enjoy the best offers from every business — from fashion and food to tech and travel. We’re redefining the way you shop smarter.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: bodySize,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Wrap(
              spacing: 40.0,
              runSpacing: 40.0,
              alignment: WrapAlignment.center,
              children: [
                _FeatureCard(
                  icon: Icons.explore,
                  title: 'Explore Offers',
                  isMobile: isMobile,
                ),
                _FeatureCard(
                  icon: Icons.compare_arrows,
                  title: 'Compare Deals',
                  isMobile: isMobile,
                ),
                _FeatureCard(
                  icon: Icons.bookmark_border,
                  title: 'Save Favorites',
                  isMobile: isMobile,
                ),
                _FeatureCard(
                  icon: Icons.location_on,
                  title: 'Location-Based Search',
                  isMobile: isMobile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. Optional: Countdown Section ---
class CountdownSection extends StatefulWidget {
  const CountdownSection({super.key});

  @override
  State<CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends State<CountdownSection> {
  final DateTime _launchDate = DateTime.now().add(const Duration(days: 30));
  Duration _timeRemaining = const Duration();

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _timeRemaining = _launchDate.difference(DateTime.now());
    });
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining.isNegative) return const SizedBox.shrink();

    String days = _timeRemaining.inDays.toString().padLeft(2, '0');
    String hours = (_timeRemaining.inHours % 24).toString().padLeft(2, '0');
    String minutes = (_timeRemaining.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_timeRemaining.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Launch In:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeCard(value: days, unit: 'Days'),
              _TimeCard(value: hours, unit: 'Hours'),
              _TimeCard(value: minutes, unit: 'Minutes'),
              _TimeCard(value: seconds, unit: 'Seconds'),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 4. Footer Section ---
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      alignment: Alignment.center,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Developed by ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFFFD700); // yellow on hover
                }
                return Colors.white70; // default
              }),
              overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
            ),
            onPressed: () {
              // Open legendaryone.in (I can add url_launcher on request)
            },
            child: const Text(
              'Legendary One',
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Components (Styling) ---
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6A11CB).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isMobile;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isMobile ? 150 : 200,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha((0.15 * 255).round()),
                  Colors.white.withAlpha((0.05 * 255).round()),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).round()),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withAlpha((0.1 * 255).round()),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ).createShader(bounds);
              },
              child: Icon(icon, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha((0.3 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String value;
  final String unit;

  const _TimeCard({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SubtleGlowText(
            text: value,
            fontSize: 64,
            fontWeight: FontWeight.bold,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFF8E2DE2)],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class SubtleGlowText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final LinearGradient? gradient;
  final double? letterSpacing;

  const SubtleGlowText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w600,
    this.color = Colors.white,
    this.gradient,
    this.letterSpacing,
  });

  @override
  State<SubtleGlowText> createState() => _SubtleGlowTextState();
}

class _SubtleGlowTextState extends State<SubtleGlowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        TextStyle style = TextStyle(
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          color: widget.color,
          letterSpacing: widget.letterSpacing,
          shadows: [
            Shadow(
              color: widget.color.withAlpha(
                ((_glowAnimation.value * 0.6) * 255).round(),
              ),
              blurRadius: 12.0 * _glowAnimation.value,
            ),
            Shadow(
              color: widget.color.withAlpha(
                ((_glowAnimation.value * 0.3) * 255).round(),
              ),
              blurRadius: 24.0 * _glowAnimation.value,
            ),
          ],
        );

        if (widget.gradient != null) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return widget.gradient!.createShader(bounds);
            },
            child: Text(
              widget.text,
              style: style.copyWith(color: Colors.white),
            ),
          );
        }

        return Text(widget.text, style: style);
      },
    );
  }
}

class SocialIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const SocialIcon({super.key, required this.icon, this.onTap});

  @override
  State<SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<SocialIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
            _controller.forward();
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
            _controller.reverse();
          });
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(100),
                  hoverColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered
                          ? Colors.white.withAlpha((0.15 * 255).round())
                          : Colors.white.withAlpha((0.1 * 255).round()),
                      border: Border.all(
                        color: _isHovered
                            ? Colors.white.withAlpha((0.5 * 255).round())
                            : Colors.white.withAlpha((0.2 * 255).round()),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(
                            ((_isHovered ? 0.15 : 0.05) * 255).round(),
                          ),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white.withAlpha(
                        ((_isHovered ? 1 : 0.8) * 255).round(),
                      ),
                      size: 24,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BlurredCircle extends StatelessWidget {
  final double size;
  final Color color;

  const BlurredCircle({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha((0.7 * 255).round()),
            color.withAlpha((0.5 * 255).round()),
            color.withAlpha((0.2 * 255).round()),
            color.withAlpha((0.0 * 255).round()),
          ],
          stops: const [0.2, 0.5, 0.8, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.4 * 255).round()),
            blurRadius: size / 1.5,
            spreadRadius: size / 6,
          ),
          BoxShadow(
            color: color.withAlpha((0.2 * 255).round()),
            blurRadius: size,
            spreadRadius: size / 3,
          ),
        ],
      ),
    );
  }
}
