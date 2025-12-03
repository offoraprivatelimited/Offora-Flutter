import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> _shareOffer() async {
    try {
      final discount =
          ((1 - (widget.offer.discountPrice / widget.offer.originalPrice)) *
                  100)
              .toStringAsFixed(0);
      final text = '''
🎉 Check out this amazing offer!

${widget.offer.title}

💰 Offer Price: ₹${widget.offer.discountPrice.toStringAsFixed(0)}
🏷️ Original Price: ₹${widget.offer.originalPrice.toStringAsFixed(0)}
✨ Save $discount%!

${widget.offer.description}

Download Offora app to get this offer!
''';
      await Share.share(text, subject: widget.offer.title);
    } catch (e) {
      _showMessage('Failed to share offer');
    }
  }

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
    final discount = ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
        .toStringAsFixed(0);

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium header with title and action buttons
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    offer.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkBlue,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon:
                              _isSaved ? Icons.favorite : Icons.favorite_border,
                          label: _isSaved ? 'Saved' : 'Save',
                          onPressed: _toggleSave,
                          isActive: _isSaved,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon:
                              _isInCompare ? Icons.done : Icons.compare_arrows,
                          label: _isInCompare ? 'In Compare' : 'Compare',
                          onPressed: _toggleCompare,
                          isActive: _isInCompare,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onPressed: _shareOffer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Price details with premium card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0B84D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Prices
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currency.format(offer.discountPrice),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkBlue,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          currency.format(offer.originalPrice),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You save ${currency.format(offer.originalPrice - offer.discountPrice)}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offer.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.7,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Validity
            if (offer.startDate != null || offer.endDate != null) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offer Validity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (offer.startDate != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: AppColors.darkBlue),
                          const SizedBox(width: 12),
                          Text(
                            'Start: ${DateFormat('MMM d, yyyy').format(offer.startDate!)}',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    if (offer.endDate != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.event,
                              size: 18, color: AppColors.darkBlue),
                          const SizedBox(width: 12),
                          Text(
                            'Ends: ${DateFormat('MMM d, yyyy').format(offer.endDate!)}',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
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
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms & Conditions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      offer.terms!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Action button widget for save, compare, and share
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFF0B84D).withAlpha(25) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isActive ? const Color(0xFFF0B84D) : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFFF0B84D) : AppColors.darkBlue,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color:
                      isActive ? const Color(0xFFF0B84D) : AppColors.darkBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
