import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  static const String routeName = '/pending-approval';

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _statusSub;

  @override
  void initState() {
    super.initState();
    _startListeningForStatusChanges();
  }

  void _startListeningForStatusChanges() {
    final auth = context.read<AuthService>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    final firestore = FirebaseFirestore.instance;
    final pendingRef = firestore
        .collection('clients')
        .doc('pending')
        .collection('clients')
        .doc(uid);

    _statusSub = pendingRef.snapshots().listen((snap) async {
      if (!mounted) return;

      if (!snap.exists) {
        // pending doc removed: check approved or rejected
        final approvedSnap = await firestore
            .collection('clients')
            .doc('approved')
            .collection('clients')
            .doc(uid)
            .get();
        if (approvedSnap.exists) {
          // Approved! Refresh auth and navigate to dashboard
          await auth.refreshProfile();
          if (!mounted) return;
          context.goNamed('client-dashboard');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been approved! Welcome.'),
            ),
          );
          return;
        }

        final rejectedSnap = await firestore
            .collection('clients')
            .doc('rejected')
            .collection('clients')
            .doc(uid)
            .get();
        if (rejectedSnap.exists) {
          // Rejected! Refresh auth and navigate to rejection page
          await auth.refreshProfile();
          if (!mounted) return;
          context.goNamed('rejection');
          return;
        }
      }
      // Still pending or not found — remain on this page
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

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
    // Premium theme colors
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
              // Decorative shapes
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
                        darkBlue.withAlpha(153),
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

              // Sign out floating action (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.white.withAlpha(230),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  child: IconButton(
                    tooltip: 'Sign out',
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_outlined, color: darkBlue),
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
                              // Icon badge
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
                                  Icons.hourglass_bottom_outlined,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Your account is under review',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: darkBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'We are reviewing your business profile to ensure it meets our compliance standards. This typically takes 1–2 business days.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              // Details card
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Your details',
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: darkBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _DetailRow(
                                      label: 'Business',
                                      value:
                                          auth.currentUser?.businessName ?? '—',
                                    ),
                                    const SizedBox(height: 8),
                                    _DetailRow(
                                      label: 'Contact',
                                      value: auth.currentUser?.contactPerson ??
                                          '—',
                                    ),
                                    const SizedBox(height: 8),
                                    _DetailRow(
                                      label: 'Email',
                                      value: auth.currentUser?.email ?? '—',
                                    ),
                                    const SizedBox(height: 8),
                                    _DetailRow(
                                      label: 'Phone',
                                      value:
                                          auth.currentUser?.phoneNumber ?? '—',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),
                              Text(
                                'We\'ll notify you via email once your account is approved. You can safely sign out and check back later.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),

                              // Sign out CTA
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const darkBlue = Color(0xFF1F477D);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}
