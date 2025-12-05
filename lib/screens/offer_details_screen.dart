import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Offer) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid offer data'),
        ),
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
  final PageController _pageController = PageController();
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final discount =
        ((1 - (widget.offer.discountPrice / widget.offer.originalPrice)) * 100)
            .toStringAsFixed(0);
    final text = 'Check out this amazing offer!\n\n'
        '${widget.offer.title}\n\n'
        'Offer Price: ₹${widget.offer.discountPrice.toStringAsFixed(0)}\n'
        'Original Price: ₹${widget.offer.originalPrice.toStringAsFixed(0)}\n'
        'Save $discount%!\n\n'
        '${widget.offer.description}\n\n'
        'Get this offer now: https://offora.in/offers/${widget.offer.id}\n\n'
        'Download Offora app: https://offora.in';

    if (kIsWeb) {
      // On web, show share options dialog
      _showWebShareDialog(text);
    } else {
      // On mobile (Android/iOS), use native share sheet
      try {
        await Share.share(
          text,
          subject: widget.offer.title,
        );
      } catch (e) {
        if (mounted) {
          _showMessage('Unable to share at this time');
        }
      }
    }
  }

  void _showWebShareDialog(String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Offer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // WhatsApp
                  _ShareOption(
                    icon: Icons.phone,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(context);
                      _shareToWhatsApp(text);
                    },
                  ),

                  // Facebook
                  _ShareOption(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      Navigator.pop(context);
                      _shareToFacebook();
                    },
                  ),

                  // Twitter/X
                  _ShareOption(
                    icon: Icons.close,
                    label: 'Twitter',
                    color: Colors.black,
                    onTap: () {
                      Navigator.pop(context);
                      _shareToTwitter(text);
                    },
                  ),

                  // Copy to clipboard
                  _ShareOption(
                    icon: Icons.content_copy,
                    label: 'Copy to Clipboard',
                    color: Colors.grey.shade700,
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(ClipboardData(text: text));
                      _showMessage('Copied to clipboard!');
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareToWhatsApp(String text) async {
    final encodedText = Uri.encodeComponent(text);
    final url = Uri.parse('https://wa.me/?text=$encodedText');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showMessage('Could not open WhatsApp');
      }
    }
  }

  Future<void> _shareToFacebook() async {
    // Facebook doesn't support pre-filled text, so just open Facebook
    final url = Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=https://offora.com');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showMessage('Could not open Facebook');
      }
    }
  }

  Future<void> _shareToTwitter(String text) async {
    final encodedText = Uri.encodeComponent(text);
    final url = Uri.parse('https://twitter.com/intent/tweet?text=$encodedText');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showMessage('Could not open Twitter');
      }
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
    final images =
        (offer.imageUrls ?? []).where((url) => url.isNotEmpty).toList();
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final discount = ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
        .toStringAsFixed(0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F9FD), Color(0xFFEFF3FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(offer, images, currency, discount),
            const SizedBox(height: 12),
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
                    color: Colors.black.withOpacity(0.03),
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

            const SizedBox(height: 12),
            _buildHighlights(offer),
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

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(Offer offer, List<String> images, NumberFormat currency,
      String discount) {
    final hasImages = images.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: hasImages
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final url = images[index];
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _buildImagePlaceholder();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        );
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                      Colors.black.withOpacity(0.45),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: _buildBadge('Limited time', Icons.flash_on_rounded),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Row(
                children: [
                  _buildCircleIconButton(
                    icon: _isSaved ? Icons.favorite : Icons.favorite_border,
                    onTap: _toggleSave,
                    isActive: _isSaved,
                  ),
                  const SizedBox(width: 10),
                  _buildCircleIconButton(
                    icon: Icons.share_outlined,
                    onTap: _shareOffer,
                  ),
                ],
              ),
            ),
            if (hasImages && images.length > 1)
              Positioned(
                bottom: 14,
                right: 14,
                child: _buildImageCount(images.length),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE9F1FF), Color(0xFFE0E9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.darkBlue,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.darkBlue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.brightGold : AppColors.darkBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildImageCount(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_currentImageIndex + 1}/$total',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHighlights(Offer offer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Highlights',
            style: TextStyle(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _factChip('Type', _formatOfferType(offer.offerType),
                  Icons.local_offer_outlined),
              _factChip('Category', _formatOfferCategory(offer.offerCategory),
                  Icons.layers_outlined),
              if (offer.minimumPurchase != null)
                _factChip(
                  'Min spend',
                  '₹${offer.minimumPurchase!.toStringAsFixed(0)}',
                  Icons.account_balance_wallet_outlined,
                ),
              if (offer.maxUsagePerCustomer != null)
                _factChip(
                  'Per customer',
                  '${offer.maxUsagePerCustomer} uses',
                  Icons.repeat_one_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatOfferType(OfferType type) {
    switch (type) {
      case OfferType.percentageDiscount:
        return 'Percent off';
      case OfferType.flatDiscount:
        return 'Flat discount';
      case OfferType.buyXGetYPercentOff:
        return 'Buy X Get Y%';
      case OfferType.buyXGetYRupeesOff:
        return 'Buy X Get ₹Y';
      case OfferType.bogo:
        return 'Buy One Get One';
      case OfferType.productSpecific:
        return 'Product specific';
      case OfferType.serviceSpecific:
        return 'Service specific';
      case OfferType.bundleDeal:
        return 'Bundle deal';
    }
  }

  String _formatOfferCategory(OfferCategory category) {
    switch (category) {
      case OfferCategory.product:
        return 'Products';
      case OfferCategory.service:
        return 'Services';
      case OfferCategory.both:
        return 'Products & Services';
    }
  }

  Widget _factChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.darkBlue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
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

// Share option widget for web share dialog
class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
