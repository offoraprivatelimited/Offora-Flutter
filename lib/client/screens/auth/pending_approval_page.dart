import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'rejection_page.dart';

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
          Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
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
          Navigator.of(context).pushReplacementNamed(RejectionPage.routeName);
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
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approval'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.hourglass_bottom_outlined,
                      size: 56,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your account is under review',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We are reviewing your business profile to ensure it meets our compliance standards. This typically takes 1–2 business days.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(128),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your details',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Business',
                          value: auth.currentUser?.businessName ?? '—',
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          label: 'Contact',
                          value: auth.currentUser?.contactPerson ?? '—',
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          label: 'Email',
                          value: auth.currentUser?.email ?? '—',
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          label: 'Phone',
                          value: auth.currentUser?.phoneNumber ?? '—',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'We\'ll notify you via email once your account is approved. You can safely sign out and check back later.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _signOut,
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
            ),
          ),
        ),
      ],
    );
  }
}
