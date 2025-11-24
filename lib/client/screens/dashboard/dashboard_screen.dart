import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/offer.dart';
import '../../../services/auth_service.dart';
import '../../services/offer_service.dart';
import '../auth/login_screen.dart';
import '../offers/offer_form_screen.dart';
import '../../../models/client_panel_stage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currency = NumberFormat.currency(symbol: '₹');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthService>();
    if (auth.stage != ClientPanelStage.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      });
    }
  }

  Future<void> _createOffer() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      return;
    }

    if (!(user.isApproved)) {
      _showMessage(
        'Your account is awaiting approval. You can draft offers once approved.',
      );
      return;
    }

    final result = await Navigator.of(
      context,
    ).pushNamed(OfferFormScreen.routeName);
    if (result == true) {
      _showMessage('Offer submitted for moderator approval.');
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signOut() async {
    await context.read<AuthService>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Client Workspace')),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.businessName ?? 'Business',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.campaign_outlined),
                      title: const Text('My Offers'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_outlined),
                    label: const Text('Sign out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (user?.isApproved ?? false)
          ? FloatingActionButton.extended(
              onPressed: _createOffer,
              icon: const Icon(Icons.add),
              label: const Text('New offer'),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: user == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _OffersSection(
                        currency: _currency,
                        userId: user.uid,
                        canCreateOffers: user.isApproved,
                        onCreateOffer: _createOffer,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OffersSection extends StatelessWidget {
  const _OffersSection({
    required this.currency,
    required this.userId,
    required this.canCreateOffers,
    required this.onCreateOffer,
  });

  final NumberFormat currency;
  final String userId;
  final bool canCreateOffers;
  final VoidCallback onCreateOffer;

  @override
  Widget build(BuildContext context) {
    final offerService = context.read<OfferService>();
    return StreamBuilder<List<Offer>>(
      stream: offerService.watchClientOffers(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final offers = snapshot.data ?? const <Offer>[];

        return DefaultTabController(
          length: 5,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Upload new offer'),
                  Tab(text: 'Live offers'),
                  Tab(text: 'Expired'),
                  Tab(text: 'Rejected'),
                  Tab(text: 'Pending approval'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    // Upload tab
                    Center(
                      child: _EmptyOffersState(
                        canCreateOffer: canCreateOffers,
                        onCreateOffer: onCreateOffer,
                      ),
                    ),
                    // Live offers: approved and not expired
                    _OffersList(
                      offers: offers
                          .where(
                            (o) =>
                                o.isApproved &&
                                (o.endDate == null ||
                                    o.endDate!.isAfter(DateTime.now())),
                          )
                          .toList(),
                      currency: currency,
                    ),
                    // Expired: endDate before now
                    _OffersList(
                      offers: offers
                          .where(
                            (o) =>
                                o.endDate != null &&
                                o.endDate!.isBefore(DateTime.now()),
                          )
                          .toList(),
                      currency: currency,
                    ),
                    // Rejected
                    _OffersList(
                      offers: offers.where((o) => o.isRejected).toList(),
                      currency: currency,
                    ),
                    // Pending
                    _OffersList(
                      offers: offers.where((o) => o.isPending).toList(),
                      currency: currency,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OffersList extends StatelessWidget {
  const _OffersList({required this.offers, required this.currency});

  final List<Offer> offers;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const Center(child: Text('No offers in this section'));
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 4),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _OfferCard(offer: offer, currency: currency);
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.currency});

  final Offer offer;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusChip = _OfferStatusChip(status: offer.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        offer.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                statusChip,
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoPill(
                  icon: Icons.price_check_outlined,
                  label: 'Original',
                  value: currency.format(offer.originalPrice),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                _InfoPill(
                  icon: Icons.sell_outlined,
                  label: 'Offer price',
                  value: currency.format(offer.discountPrice),
                  color: theme.colorScheme.primary,
                ),
                if (offer.startDate != null)
                  _InfoPill(
                    icon: Icons.event_available_outlined,
                    label: 'Starts',
                    value: DateFormat('d MMM').format(offer.startDate!),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                if (offer.endDate != null)
                  _InfoPill(
                    icon: Icons.event_busy_outlined,
                    label: 'Ends',
                    value: DateFormat('d MMM').format(offer.endDate!),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
            if (offer.terms != null && offer.terms!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Terms & conditions',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(offer.terms!, style: theme.textTheme.bodyMedium),
            ],
            if (offer.isRejected && offer.rejectionReason != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Moderator note: ${offer.rejectionReason}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OfferStatusChip extends StatelessWidget {
  const _OfferStatusChip({required this.status});

  final OfferApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    late Color background;
    late Color foreground;
    late String label;
    late IconData icon;

    switch (status) {
      case OfferApprovalStatus.pending:
        background = theme.colorScheme.secondaryContainer;
        foreground = theme.colorScheme.onSecondaryContainer;
        label = 'Pending review';
        icon = Icons.hourglass_bottom_outlined;
        break;
      case OfferApprovalStatus.approved:
        background = theme.colorScheme.primaryContainer;
        foreground = theme.colorScheme.onPrimaryContainer;
        label = 'Approved';
        icon = Icons.verified_outlined;
        break;
      case OfferApprovalStatus.rejected:
        background = theme.colorScheme.errorContainer;
        foreground = theme.colorScheme.onErrorContainer;
        label = 'Needs changes';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withAlpha((0.35 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOffersState extends StatelessWidget {
  const _EmptyOffersState({
    required this.canCreateOffer,
    required this.onCreateOffer,
  });

  final bool canCreateOffer;
  final VoidCallback onCreateOffer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No offers yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canCreateOffer
                ? 'Create your first offer to submit it for Offora approval.'
                : 'Once your account is approved you can start drafting offers for the marketplace.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (canCreateOffer)
            OutlinedButton.icon(
              onPressed: onCreateOffer,
              icon: const Icon(Icons.add),
              label: const Text('Draft an offer'),
            ),
        ],
      ),
    );
  }
}
