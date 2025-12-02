import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/offer.dart';
import '../../../services/auth_service.dart';
import '../../services/offer_service.dart';
import '../auth/login_screen.dart';
import '../offers/new_offer_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currency = NumberFormat.currency(symbol: '₹');
  final darkBlue = const Color(0xFF1F477D);
  final brightGold = const Color(0xFFF0B84D);
  final darkerGold = const Color(0xFFA3834D);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthService>();
    // Only redirect to login when the user is not authenticated.
    // Allow users who are signed in but pending approval to access the
    // dashboard so they can draft offers. Previously we redirected any
    // non-active stage which prevented drafting.
    if (!auth.isLoggedIn) {
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

    // Allow users who are not yet approved to open the offer form and
    // create drafts. We still notify them about approval requirements.
    if (!(user.isApproved)) {
      _showMessage(
        'Your account is awaiting approval. You can draft offers; they will be submitted for review once approved.',
      );
    }

    final result =
        await Navigator.of(context).pushNamed(NewOfferFormScreen.routeName);
    if (!mounted) return; // guard against using context across async gaps
    if (result == true) {
      if (user.isApproved) {
        _showMessage('Offer submitted for moderator approval.');
      } else {
        _showMessage(
            'Offer saved as a draft. It will be submitted when your account is approved.');
      }
    }
  }

  Future<void> _editOffer(Offer offer) async {
    final result = await Navigator.of(context).pushNamed(
      NewOfferFormScreen.routeName,
      arguments: offer,
    );
    if (!mounted) return; // ensure widget still mounted before using context
    if (result == true) {
      _showMessage('Offer updated successfully.');
    }
  }

  Future<void> _deleteOffer(Offer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text('Are you sure you want to delete "${offer.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        // Avoid using context across async gap without mounted guard
        final service = context.read<OfferService>();
        await service.deleteOffer(offer.id);
        if (!mounted) return;
        _showMessage('Offer deleted successfully.');
      } catch (e) {
        if (!mounted) return;
        _showMessage('Failed to delete offer: $e');
      }
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Header matching HomeScreen style
                SliverToBoxAdapter(
                  child: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 1,
                    toolbarHeight: 44,
                    automaticallyImplyLeading: false,
                    title: Row(
                      children: [
                        SizedBox(
                          height: 28,
                          child: Image.asset(
                            'images/logo/original/Text_without_logo_without_background.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkBlue.withAlpha(13),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: brightGold.withAlpha(76),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: darkBlue.withAlpha(179),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.businessName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: darkBlue,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 16, color: darkerGold),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user.address,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Offers section header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Offers',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: darkBlue,
                                  ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _createOffer,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New offer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brightGold,
                                foregroundColor: darkBlue,
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Offers list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _OffersSection(
                      currency: _currency,
                      userId: user.uid,
                      // Allow creating offers (drafts) for signed-in users
                      canCreateOffers: true,
                      onCreateOffer: _createOffer,
                      onEditOffer: _editOffer,
                      onDeleteOffer: _deleteOffer,
                      darkBlue: darkBlue,
                      brightGold: brightGold,
                      darkerGold: darkerGold,
                    ),
                  ),
                ),
              ],
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
    required this.onEditOffer,
    required this.onDeleteOffer,
    required this.darkBlue,
    required this.brightGold,
    required this.darkerGold,
  });

  final NumberFormat currency;
  final String userId;
  final bool canCreateOffers;
  final VoidCallback onCreateOffer;
  final Function(Offer) onEditOffer;
  final Function(Offer) onDeleteOffer;
  final Color darkBlue;
  final Color brightGold;
  final Color darkerGold;

  @override
  Widget build(BuildContext context) {
    final offerService = context.read<OfferService>();
    return StreamBuilder<List<Offer>>(
      stream: offerService.watchClientOffers(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final offers = snapshot.data ?? [];

        if (offers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.campaign_outlined,
                      size: 64, color: darkBlue.withAlpha(76)),
                  const SizedBox(height: 16),
                  Text(
                    'No offers yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: darkBlue,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first offer to get started',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  if (canCreateOffers) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onCreateOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brightGold,
                        foregroundColor: darkBlue,
                      ),
                      child: const Text('Create first offer'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            final discount =
                ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
                    .toStringAsFixed(0);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: darkBlue,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [brightGold, darkerGold],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$discount%',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(offer.status).withAlpha(38),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                offer.status.name.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: _getStatusColor(offer.status),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: currency.format(offer.discountPrice),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: brightGold,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' / ${currency.format(offer.originalPrice)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.grey.shade500,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => onEditOffer(offer),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkBlue,
                            side: BorderSide(color: darkBlue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => onDeleteOffer(offer),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(OfferApprovalStatus status) {
    switch (status) {
      case OfferApprovalStatus.pending:
        return Colors.orange;
      case OfferApprovalStatus.approved:
        return Colors.green;
      case OfferApprovalStatus.rejected:
        return Colors.red;
    }
  }
}
