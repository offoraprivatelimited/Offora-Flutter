import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/offer.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/offer_service.dart';
import '../offers/new_offer_form_screen.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../user/screens/offer_details_screen.dart';
import '../../../../core/errors/error_messages.dart';

class ManageOffersScreen extends StatefulWidget {
  static const String routeName = '/manage-offers';

  final Function(Offer)? onEditOffer;
  final Function(Offer)? onDeleteOffer;

  const ManageOffersScreen({
    super.key,
    this.onEditOffer,
    this.onDeleteOffer,
  });

  @override
  State<ManageOffersScreen> createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends State<ManageOffersScreen> {
  final _currency = NumberFormat.currency(symbol: '₹');
  final darkBlue = const Color(0xFF1F477D);
  final brightGold = const Color(0xFFF0B84D);
  String _filterStatus = 'all'; // all, pending, approved, rejected
  bool _redirectingToLogin = false;

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _viewOfferDetails(Offer offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FD),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: OfferDetailsContent(offer: offer),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editOffer(Offer offer) async {
    // Always fetch the latest offer from Firestore before editing
    final offerService = Provider.of<OfferService>(context, listen: false);
    final auth = context.read<AuthService>();
    final clientId = auth.currentUser?.uid ?? '';

    final status = offer.status.name; // 'pending', 'approved', 'rejected'
    final latestOffer =
        await offerService.getOffer(offerId: offer.id, status: status);

    if (!mounted) return;

    if (widget.onEditOffer != null) {
      if (latestOffer != null) {
        widget.onEditOffer!(latestOffer);
      } else {
        _showMessage('Could not load offer details.');
      }
      return;
    }

    if (latestOffer == null) {
      _showMessage('Could not load offer details.');
      return;
    }

    // Fallback to modal for standalone use
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 1.0,
        maxChildSize: 1.0,
        expand: true,
        builder: (context, scrollController) {
          return NewOfferFormScreen(
            clientId: clientId,
            offerToEdit: latestOffer,
          );
        },
      ),
    );
    if (!mounted) return;
    // Refresh offers after edit
    if (result == true) {
      _showMessage('Offer updated successfully.');
      setState(() {});
    }
  }

  Future<void> _deleteOffer(Offer offer) async {
    // If callback is provided, use it (for embedded use in ClientMainScreen)
    if (widget.onDeleteOffer != null) {
      widget.onDeleteOffer!(offer);
      return;
    }

    // Fallback to dialog for standalone use
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Offer',
          style: TextStyle(
            color: Color(0xFF1F477D),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${offer.title}"?',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
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
        await context.read<OfferService>().deleteOffer(offer.id);
        if (!mounted) return;
        _showMessage('Offer deleted successfully.');
      } catch (e) {
        if (!mounted) return;
        _showMessage(ErrorMessages.friendlyErrorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    if (user == null) {
      if (!_redirectingToLogin) {
        _redirectingToLogin = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.goNamed('client-login');
        });
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: ResponsivePage(
          child: Column(
            children: [
              // Filter chips
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _filterStatus == 'all',
                        onTap: () => setState(() => _filterStatus = 'all'),
                        color: darkBlue,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pending',
                        isSelected: _filterStatus == 'pending',
                        onTap: () => setState(() => _filterStatus = 'pending'),
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Approved',
                        isSelected: _filterStatus == 'approved',
                        onTap: () => setState(() => _filterStatus = 'approved'),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Rejected',
                        isSelected: _filterStatus == 'rejected',
                        onTap: () => setState(() => _filterStatus = 'rejected'),
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Expired',
                        isSelected: _filterStatus == 'expired',
                        onTap: () => setState(() => _filterStatus = 'expired'),
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              // Offers list
              Expanded(
                child: StreamBuilder<List<Offer>>(
                  stream: _filterStatus == 'all'
                      ? context
                          .read<OfferService>()
                          .watchClientOffersByStatus(user.uid)
                      : context.read<OfferService>().watchClientOffersByStatus(
                          user.uid,
                          status: _filterStatus),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    var offers = snapshot.data ?? [];

                    if (offers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.campaign_outlined,
                                  size: 64,
                                  color: darkBlue.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text(
                                _filterStatus == 'all'
                                    ? 'No offers yet'
                                    : 'No $_filterStatus offers',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final width = MediaQuery.of(context).size.width;
                    final crossCount = width < 500 ? 1 : (width < 800 ? 2 : 3);
                    final childAspectRatio = width < 500 ? 1.35 : 0.95;

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        return _OfferCard(
                          offer: offer,
                          currency: _currency,
                          darkBlue: darkBlue,
                          brightGold: brightGold,
                          onEdit: () => _editOffer(offer),
                          onDelete: () => _deleteOffer(offer),
                          onViewDetails: () => _viewOfferDetails(offer),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final NumberFormat currency;
  final Color darkBlue;
  final Color brightGold;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  const _OfferCard({
    required this.offer,
    required this.currency,
    required this.darkBlue,
    required this.brightGold,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  Color _getStatusColor(OfferApprovalStatus status, {bool isExpired = false}) {
    if (isExpired) return Colors.grey;
    switch (status) {
      case OfferApprovalStatus.pending:
        return Colors.orange;
      case OfferApprovalStatus.approved:
        return Colors.green;
      case OfferApprovalStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(OfferApprovalStatus status, {bool isExpired = false}) {
    if (isExpired) return 'EXPIRED';
    return status.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final discount = ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
        .toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image if available
          if (offer.imageUrls != null && offer.imageUrls!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                offer.imageUrls!.first,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 28),
                  );
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offer.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: darkBlue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [brightGold, const Color(0xFFA3834D)],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Status:',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(offer.status,
                                      isExpired: offer.isExpired)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: _getStatusColor(offer.status,
                                    isExpired: offer.isExpired),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              _getStatusText(offer.status,
                                  isExpired: offer.isExpired),
                              style: TextStyle(
                                color: _getStatusColor(offer.status,
                                    isExpired: offer.isExpired),
                                fontWeight: FontWeight.w700,
                                fontSize: 8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Price: ${currency.format(offer.discountPrice)}',
                      style: TextStyle(
                        color: brightGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onViewDetails,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(Icons.visibility,
                          size: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: darkBlue, width: 0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(Icons.edit, size: 12, color: darkBlue),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child:
                          const Icon(Icons.delete, size: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: const BoxConstraints(minWidth: 75),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
