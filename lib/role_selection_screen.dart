import 'package:flutter/material.dart';
import 'client/screens/auth/login_screen.dart' as client;

class RoleSelectionScreen extends StatelessWidget {
  static const String routeName = '/role-selection';

  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);
    const darkerGold = Color(0xFFA3834D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 760;
          return Stack(
            children: [
              // Decorative background - modified style
              Positioned(
                top: -constraints.maxWidth * 0.15,
                right: -constraints.maxWidth * 0.25,
                child: Container(
                  width: constraints.maxWidth * 0.7,
                  height: constraints.maxWidth * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        brightGold.withAlpha(230),
                        brightGold.withAlpha(102)
                      ],
                      center: Alignment.topRight,
                      radius: 0.9,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -constraints.maxWidth * 0.2,
                left: -constraints.maxWidth * 0.15,
                child: Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxWidth * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [darkBlue.withAlpha(204), darkBlue.withAlpha(77)],
                      center: Alignment.bottomLeft,
                      radius: 0.9,
                    ),
                  ),
                ),
              ),
              // Main content
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 40 : 24, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header section
                        Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: darkerGold.withAlpha(77),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'images/logo/original/Logo_without_text_without_background.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Welcome to Offora',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: darkBlue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Choose how you want to use Offora',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Role cards
                        Column(
                          children: [
                            // User card
                            _RoleCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Browse & Shop',
                              description:
                                  'Discover amazing offers from local businesses',
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/user-login',
                                );
                              },
                              accentColor: brightGold,
                              isFirst: true,
                            ),
                            const SizedBox(height: 20),
                            // Shopowner card
                            _RoleCard(
                              icon: Icons.store_outlined,
                              title: 'Publish & Manage',
                              description:
                                  'Create offers and manage your business',
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  client.LoginScreen.routeName,
                                  arguments: {'role': 'shopowner'},
                                );
                              },
                              accentColor: darkBlue,
                              isFirst: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final Color accentColor;
  final bool isFirst;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.accentColor,
    required this.isFirst,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withAlpha(230),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withAlpha(_isHovered ? 77 : 38),
                blurRadius: _isHovered ? 24 : 12,
                spreadRadius: _isHovered ? 2 : 0,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
            border: Border.all(
              color: widget.accentColor.withAlpha(51),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor,
                        widget.accentColor.withAlpha(179),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F477D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor,
                        widget.accentColor.withAlpha(204),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withAlpha(77),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
