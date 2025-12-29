import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/services/auth_service.dart';

class RejectionPage extends StatefulWidget {
  const RejectionPage({super.key});

  static const String routeName = '/rejection';

  @override
  State<RejectionPage> createState() => _RejectionPageState();
}

class _RejectionPageState extends State<RejectionPage> {
  Future<void> _signOut() async {
    await context.read<AuthService>().signOut();
    if (!mounted) return;
    // Use go() instead of goNamed to clear the entire navigation stack
    context.go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthService>();
    final rejectionReason =
        auth.currentUser?.rejectionReason ?? 'No reason provided.';
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
              Positioned(
                top: -constraints.maxWidth * 0.25,
                left: -constraints.maxWidth * 0.18,
                child: Container(
                  width: constraints.maxWidth * 0.9,
                  height: constraints.maxWidth * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        darkBlue.withAlpha(245),
                        darkBlue.withAlpha(153)
                      ],
                      center: Alignment.topLeft,
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -constraints.maxWidth * 0.12,
                right: -constraints.maxWidth * 0.22,
                child: Container(
                  width: constraints.maxWidth * 0.68,
                  height: constraints.maxWidth * 0.68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        brightGold.withAlpha(255),
                        brightGold.withAlpha(217)
                      ],
                      center: Alignment.topRight,
                      radius: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkerGold.withAlpha(56),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -constraints.maxWidth * 0.22,
                left: -constraints.maxWidth * 0.18,
                child: Container(
                  width: constraints.maxWidth * 1.2,
                  height: constraints.maxWidth * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(constraints.maxWidth),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [darkerGold.withAlpha(46), Colors.transparent],
                    ),
                  ),
                ),
              ),

              // Top-left title / no back
              Positioned(
                top: 12,
                left: 12,
                child: Text(
                  'Application Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),
              ),

              // Content
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 720 : 520),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 28 : 16, vertical: 28),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(250),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(31),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 28),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [brightGold, darkerGold]),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: darkerGold.withAlpha(56),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(18),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Application not approved',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: darkBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Our compliance team has reviewed your submission. Unfortunately, we cannot approve your account at this time.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reason',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      rejectionReason,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ActionItem(
                                    icon: Icons.edit_outlined,
                                    title: 'Update your information',
                                    description:
                                        'Address the points mentioned above and contact our support team to resubmit your application.',
                                  ),
                                  SizedBox(height: 12),
                                  _ActionItem(
                                    icon: Icons.help_outline,
                                    title: 'Contact support',
                                    description:
                                        'Reach out to our support team for clarification or assistance in resolving the issues.',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: 220,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _signOut,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: darkBlue, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.logout_outlined,
                                          color: darkBlue),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sign out',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: darkBlue,
                                          fontWeight: FontWeight.w700,
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

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
