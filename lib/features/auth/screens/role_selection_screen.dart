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

              // Breakpoint for desktop / large screens
              final bool isDesktop = maxWidth >= 1000;

              if (isDesktop) {
                // Desktop: Split layout with hero on left, content on right
                return Row(
                  children: [
                    // Left side - Hero section with gradient and decorative elements
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              darkBlue,
                              darkBlue.withAlpha(220),
                              const Color(0xFF2A5A9F),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative circles
                            Positioned(
                              top: -60,
                              right: -60,
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: brightGold.withAlpha(30),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -80,
                              left: -80,
                              child: Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha(15),
                                ),
                              ),
                            ),
                            // Content
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(100),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Image.asset(
                                          'assets/images/logo/original/Logo_without_text_without_background.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    const Text(
                                      'Welcome to Offora',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Find the best deals and offers from local businesses in your area',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white70,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right side - Role selection options
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 40),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: darkBlue,
                                            fontSize: 28,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Choose your role to continue',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    _DesktopRoleCard(
                                      darkBlue: darkBlue,
                                      brightGold: brightGold,
                                      title: 'Shop for Offers',
                                      description:
                                          'Discover and save the best local deals',
                                      icon: Icons.shopping_bag_outlined,
                                      buttonText: 'Continue as User',
                                      onPressed: () {
                                        context
                                            .pushReplacementNamed('user-login');
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _DesktopRoleCard(
                                      darkBlue: darkBlue,
                                      brightGold: brightGold,
                                      title: 'Business Owner',
                                      description:
                                          'Create and manage exclusive offers',
                                      icon: Icons.store_outlined,
                                      buttonText: 'Continue as Shop Owner',
                                      onPressed: () {
                                        context.pushReplacementNamed(
                                            'client-login');
                                      },
                                      isPrimary: false,
                                    ),
                                    const SizedBox(height: 32),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withAlpha(50),
                                        ),
                                      ),
                                      child: const Text(
                                        "You can't create another shop owner account from this email again",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Mobile / Tablet: Original centered card layout
              Widget content = _RoleSelectionContent(
                darkBlue: darkBlue,
                brightGold: brightGold,
                darkerGold: darkerGold,
                maxHeight: maxHeight,
              );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 700,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 30,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: content,
                    ),
                  ),
                ),
              );
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
                  darkBlue.withAlpha(20),
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
                  brightGold.withAlpha(41),
                  Colors.white,
                ],
                center: Alignment.bottomRight,
                radius: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: darkerGold.withAlpha(64),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Top section
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Image.asset(
                            'assets/images/logo/original/Logo_without_text_without_background.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Welcome to Offora',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select how you want to use Offora',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    // Middle section – roles
                    Column(
                      children: [
                        const SizedBox(height: 20),
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
                        SizedBox(height: 20),
                        Text(
                          "You can't create another shop owner account from this mail account again",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: 8),
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
      shadowColor: Colors.black.withAlpha(26),
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
                  backgroundColor: darkBlue.withAlpha(15),
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
      color: Colors.white.withAlpha(217),
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: darkBlue.withAlpha(20),
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
                  side: BorderSide(color: darkBlue.withAlpha(153)),
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

class _DesktopRoleCard extends StatelessWidget {
  final Color darkBlue;
  final Color brightGold;
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _DesktopRoleCard({
    required this.darkBlue,
    required this.brightGold,
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonText,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPrimary ? darkBlue.withAlpha(10) : Colors.grey.withAlpha(10),
        border: Border.all(
          color: isPrimary ? brightGold : Colors.grey.withAlpha(100),
          width: isPrimary ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPrimary ? brightGold : Colors.grey.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPrimary ? darkBlue : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary ? darkBlue : Colors.white,
                foregroundColor: isPrimary ? Colors.white : darkBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isPrimary ? darkBlue : darkBlue,
                    width: isPrimary ? 0 : 2,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
