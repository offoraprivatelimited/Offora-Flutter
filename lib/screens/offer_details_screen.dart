import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../services/saved_offers_service.dart';
import '../services/compare_service.dart';
import '../client/models/offer.dart';

class OfferDetailsScreen extends StatefulWidget {
  static const String routeName = '/offer';
  const OfferDetailsScreen({super.key});

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Offer) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offer Details')),
        body: const Center(child: Text('Offer not found')),
      );
    }

    return Scaffold(
      body: OfferDetailsContent(offer: args),
    );
  }
}

// Extracted content for reuse in MainScreen inline display
class OfferDetailsContent extends StatefulWidget {
  final Offer offer;

  const OfferDetailsContent({super.key, required this.offer});

  @override
  State<OfferDetailsContent> createState() => _OfferDetailsContentState();
}

class _OfferDetailsContentState extends State<OfferDetailsContent> {
  // Removed unused _currentImageIndex
  bool _isSaved = false;
  bool _isInCompare = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSavedStatus();
    _checkCompareStatus();
  }

  Future<void> _checkSavedStatus() async {
    final auth = context.read<AuthService>();
    if (auth.currentUser == null) return;

    final savedService = context.read<SavedOffersService>();
    final isSaved =
        await savedService.isOfferSaved(auth.currentUser!.uid, widget.offer.id);
    if (mounted) {
      setState(() => _isSaved = isSaved);
    }
  }

  void _checkCompareStatus() {
    final compareService = context.read<CompareService>();
    setState(() => _isInCompare = compareService.isInCompare(widget.offer.id));
  }

  Future<void> _toggleSave() async {
    final auth = context.read<AuthService>();
    if (auth.currentUser == null) {
      _showMessage('Please sign in to save offers');
      return;
    }

    try {
      final savedService = context.read<SavedOffersService>();
      final newStatus = await savedService.toggleSaveOffer(
          auth.currentUser!.uid, widget.offer);
      setState(() => _isSaved = newStatus);
      _showMessage(newStatus ? 'Offer saved!' : 'Offer removed from saved');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    }
  }

  void _toggleCompare() {
    final compareService = context.read<CompareService>();

    if (compareService.isFull && !_isInCompare) {
      _showMessage('You can only compare up to 4 offers');
      return;
    }

    try {
      compareService.toggleCompare(widget.offer);
      setState(() => _isInCompare = !_isInCompare);
      _showMessage(_isInCompare
          ? 'Added to comparison (${compareService.count}/4)'
          : 'Removed from comparison');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    }
  }

  // Removed unused _shareOffer, _openMap, _callBusiness, _emailBusiness

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    // Removed unused discount variable

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    offer.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkBlue,
                        ),
                  ),
                ),

                const Divider(height: 1),

                // Price details
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlue,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _PriceRow(
                        label: 'Original Price',
                        value: currency.format(offer.originalPrice),
                        isStrikethrough: true,
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(
                        label: 'Offer Price',
                        value: currency.format(offer.discountPrice),
                        color: AppColors.brightGold,
                        isBold: true,
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(
                        label: 'You Save',
                        value: currency
                            .format(offer.originalPrice - offer.discountPrice),
                        color: Colors.green.shade700,
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Description
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlue,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        offer.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Validity
                if (offer.startDate != null || offer.endDate != null) ...[
                  const Divider(height: 1),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offer Validity',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlue,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        if (offer.startDate != null)
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Start: ${DateFormat('MMM d, yyyy').format(offer.startDate!)}',
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 15),
                              ),
                            ],
                          ),
                        if (offer.endDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.event,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Ends: ${DateFormat('MMM d, yyyy').format(offer.endDate!)}',
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 15),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Terms
                if (offer.terms != null && offer.terms!.isNotEmpty) ...[
                  const Divider(height: 1),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms & Conditions',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlue,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          offer.terms!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Save and Compare buttons below content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleSave,
                          icon: Icon(
                            _isSaved ? Icons.favorite : Icons.favorite_border,
                            color: _isSaved
                                ? AppColors.brightGold
                                : AppColors.darkBlue,
                          ),
                          label: Text(_isSaved ? 'Saved' : 'Add to Saved'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkBlue,
                            side: const BorderSide(
                                color: AppColors.darkBlue, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleCompare,
                          icon: Icon(
                            _isInCompare ? Icons.done : Icons.compare_arrows,
                            color: AppColors.darkBlue,
                          ),
                          label: Text(_isInCompare ? 'In Compare' : 'Compare'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkBlue,
                            side: const BorderSide(
                                color: AppColors.darkBlue, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // ...no bottom action bar...
      ],
    );
  }

  // Removed unused _buildActionButton and _buildPlaceholder
}

// Removed unused _InfoRow class

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;
  final bool isStrikethrough;

  const _PriceRow({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
    this.isStrikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            color: color ?? Colors.grey.shade800,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
