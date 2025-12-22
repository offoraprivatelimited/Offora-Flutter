// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  static const String routeName = '/role-selection';

  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);
    const darkerGold = Color(0xFFA3834D);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Prevent back navigation
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final maxHeight = constraints.maxHeight;

              // Simple breakpoint for desktop / large screens
              final bool isDesktop = maxWidth >= 900;

              Widget content = _RoleSelectionContent(
                darkBlue: darkBlue,
                brightGold: brightGold,
                darkerGold: darkerGold,
                maxHeight: maxHeight,
              );

              if (isDesktop) {
                // Center a fixed-width card on desktop so it looks good in wide view
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 520,
                      maxHeight: 720,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 40,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: content,
                      ),
                    ),
                  ),
                );
              }

              // Mobile / tablet full-screen
              return content;
            },
          ),
        ),
      ),
    );
  }
}

class _RoleSelectionContent extends StatelessWidget {
  final Color darkBlue;
  final Color brightGold;
  final Color darkerGold;
  final double maxHeight;

  const _RoleSelectionContent({
    required this.darkBlue,
    required this.brightGold,
    required this.darkerGold,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Light background with soft decorative shapes
        Positioned(
          top: -maxHeight * 0.25,
          left: -maxHeight * 0.20,
          child: Container(
            width: maxHeight * 0.7,
            height: maxHeight * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  darkBlue.withOpacity(0.08),
                  Colors.white,
                ],
                center: Alignment.topLeft,
                radius: 0.9,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -maxHeight * 0.30,
          right: -maxHeight * 0.15,
          child: Container(
            width: maxHeight * 0.75,
            height: maxHeight * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  brightGold.withOpacity(0.16),
                  Colors.white,
                ],
                center: Alignment.bottomRight,
                radius: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: darkerGold.withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),

        // Main column (single screen; use height fractions)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Top section
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            'assets/images/logo/original/Logo_without_text_without_background.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome to Offora',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select how you want to use Offora',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    // Middle section – roles
                    Column(
                      children: [
                        _PrimaryRoleCard(
                          darkBlue: darkBlue,
                          brightGold: brightGold,
                          title: 'Shop for Offers',
                          description:
                              'Discover and save the best local deals as a user.',
                          buttonText: 'Continue as User',
                          onPressed: () {
                            context.pushReplacementNamed('user-login');
                          },
                        ),
                        const SizedBox(height: 12),
                        _SecondaryRoleChip(
                          darkBlue: darkBlue,
                          title: 'Business Owner',
                          subtitle:
                              'Manage your shop and publish exclusive offers.',
                          buttonText: 'Continue as Shop Owner',
                          onPressed: () {
                            context.pushReplacementNamed('client-login');
                          },
                        ),
                      ],
                    ),

                    // Bottom hint
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        SizedBox(height: 24),
                        Text(
                          "You can't create another shop owner account from this mail account again",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryRoleCard extends StatelessWidget {
  final Color darkBlue;
  final Color brightGold;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const _PrimaryRoleCard({
    required this.darkBlue,
    required this.brightGold,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: darkBlue.withOpacity(0.06),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: darkBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _SecondaryRoleChip extends StatelessWidget {
  final Color darkBlue;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const _SecondaryRoleChip({
    required this.darkBlue,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: darkBlue.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.storefront_outlined,
              color: darkBlue,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkBlue,
                  side: BorderSide(color: darkBlue.withOpacity(0.6)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
