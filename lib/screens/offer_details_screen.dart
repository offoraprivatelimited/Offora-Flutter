import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
  int _currentImageIndex = 0;
  bool _isSaved = false;
  bool _isInCompare = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSavedStatus();
    _checkCompareStatus();
  }

  Future<void> _checkSavedStatus() async {
    final offer = _getOffer();
    if (offer == null) return;

    final auth = context.read<AuthService>();
    if (auth.currentUser == null) return;

    final savedService = context.read<SavedOffersService>();
    final isSaved =
        await savedService.isOfferSaved(auth.currentUser!.uid, offer.id);
    if (mounted) {
      setState(() => _isSaved = isSaved);
    }
  }

  void _checkCompareStatus() {
    final offer = _getOffer();
    if (offer == null) return;

    final compareService = context.read<CompareService>();
    setState(() => _isInCompare = compareService.isInCompare(offer.id));
  }

  Offer? _getOffer() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Offer) return args;
    return null;
  }

  Future<void> _toggleSave() async {
    final offer = _getOffer();
    if (offer == null) return;

    final auth = context.read<AuthService>();
    if (auth.currentUser == null) {
      _showMessage('Please sign in to save offers');
      return;
    }

    try {
      final savedService = context.read<SavedOffersService>();
      final newStatus =
          await savedService.toggleSaveOffer(auth.currentUser!.uid, offer);
      setState(() => _isSaved = newStatus);
      _showMessage(newStatus ? 'Offer saved!' : 'Offer removed from saved');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    }
  }

  void _toggleCompare() {
    final offer = _getOffer();
    if (offer == null) return;

    final compareService = context.read<CompareService>();

    if (compareService.isFull && !_isInCompare) {
      _showMessage('You can only compare up to 4 offers');
      return;
    }

    try {
      compareService.toggleCompare(offer);
      setState(() => _isInCompare = !_isInCompare);
      _showMessage(_isInCompare
          ? 'Added to comparison (${compareService.count}/4)'
          : 'Removed from comparison');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    }
  }

  void _shareOffer() {
    final offer = _getOffer();
    if (offer == null) return;

    Clipboard.setData(ClipboardData(
      text: '${offer.title}\n'
          'Get ${((1 - (offer.discountPrice / offer.originalPrice)) * 100).toStringAsFixed(0)}% off at ${offer.client?['businessName'] ?? 'this store'}!\n'
          'Download Offora app to claim this offer.',
    ));
    _showMessage('Offer details copied to clipboard!');
  }

  Future<void> _openMap() async {
    final offer = _getOffer();
    if (offer == null) return;

    final location = offer.client?['location'] as String? ?? '';
    if (location.isEmpty) {
      _showMessage('Location not available');
      return;
    }

    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _showMessage('Could not open maps');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offer = _getOffer();

    if (offer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offer Details')),
        body: const Center(child: Text('Offer not found')),
      );
    }

    final currency = NumberFormat.currency(symbol: '₹');
    final discount = ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
        .toStringAsFixed(0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.darkBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: _toggleSave,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareOffer,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (offer.imageUrls?.isNotEmpty == true)
                    PageView.builder(
                      itemCount: offer.imageUrls!.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          offer.imageUrls![index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        );
                      },
                    )
                  else
                    _buildPlaceholder(),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(179),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Discount badge
                  Positioned(
                    top: 60,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.brightGold, AppColors.darkerGold],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  // Image indicators
                  if (offer.imageUrls != null && offer.imageUrls!.length > 1)
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          offer.imageUrls!.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withAlpha(128),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and store info
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkBlue,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.store,
                              size: 20, color: AppColors.darkerGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              offer.client?['businessName'] ?? 'Store',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (offer.client?['location'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 20, color: AppColors.darkerGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                offer.client!['location'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
                          'Validity',
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
                                'From: ${DateFormat('MMM d, yyyy').format(offer.startDate!)}',
                                style: TextStyle(color: Colors.grey.shade700),
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
                                'Until: ${DateFormat('MMM d, yyyy').format(offer.endDate!)}',
                                style: TextStyle(color: Colors.grey.shade700),
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

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // Action buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleCompare,
                  icon: Icon(
                    _isInCompare ? Icons.done : Icons.compare_arrows,
                    size: 20,
                  ),
                  label: Text(_isInCompare ? 'In Compare' : 'Compare'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkBlue,
                    side: const BorderSide(color: AppColors.darkBlue, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _openMap,
                  icon: const Icon(Icons.directions, size: 20),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightGold,
                    foregroundColor: AppColors.darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(
        Icons.image,
        size: 100,
        color: Colors.grey.shade500,
      ),
    );
  }
}

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
