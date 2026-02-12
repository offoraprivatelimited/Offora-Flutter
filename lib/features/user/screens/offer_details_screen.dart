// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/saved_offers_service.dart';
import '../../../shared/services/compare_service.dart';
import '../../client/models/offer.dart';
import 'main_screen.dart';

enum ScreenSizeCategory { mobile, tablet, desktop }

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

    final mainState = MainScreen.globalKey.currentState;
    if (mainState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mainState.showOfferDetails(args);
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(body: OfferDetailsContent(offer: args));
  }
}

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
    try {
      final auth = context.read<AuthService>();
      if (auth.currentUser == null) return;
      final savedService = context.read<SavedOffersService>();
      final isSaved = await savedService.isOfferSaved(
          auth.currentUser!.uid, widget.offer.id);
      if (mounted) {
        setState(() => _isSaved = isSaved);
      }
    } catch (e) {
      if (kDebugMode) print('Error checking saved status: $e');
    }
  }

  void _checkCompareStatus() {
    try {
      final compareService = context.read<CompareService>();
      setState(
          () => _isInCompare = compareService.isInCompare(widget.offer.id));
    } catch (e) {
      if (kDebugMode) print('Error checking compare status: $e');
    }
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
    double displayDiscountPrice = widget.offer.discountPrice ?? 0;
    final originalPrice = widget.offer.originalPrice;
    final hasOriginalPrice = originalPrice > 0;

    // Calculate correct discount price based on offer type
    if (widget.offer.offerType == OfferType.percentageDiscount) {
      final percentOff = widget.offer.percentageOff ?? 0;
      if (percentOff > 0 && originalPrice > 0) {
        displayDiscountPrice = originalPrice * (1 - (percentOff / 100));
      }
    } else if (widget.offer.offerType == OfferType.flatDiscount) {
      final flatAmount = widget.offer.flatDiscountAmount ?? 0;
      if (flatAmount > 0 && originalPrice > 0) {
        displayDiscountPrice = originalPrice - flatAmount;
      }
    }

    final discount = hasOriginalPrice && displayDiscountPrice > 0
        ? ((1 - (displayDiscountPrice / originalPrice)) * 100)
            .toStringAsFixed(0)
        : '0';
    String text = 'Check out this amazing offer!\n\n'
        '${widget.offer.title}\n\n'
        'Offer Price: ₹${displayDiscountPrice.toStringAsFixed(0)}\n';
    if (hasOriginalPrice) {
      text += 'Original Price: ₹${originalPrice.toStringAsFixed(0)}\n';
      text += 'Save $discount%!\n\n';
    }
    text += '${widget.offer.description}\n\n'
        'Get this offer now: https://offora.in/offers/${widget.offer.id}\n\n'
        'Download Offora app: https://offora.in';

    if (kIsWeb) {
      _showWebShareDialog(text);
    } else {
      try {
        await Share.share(text, subject: widget.offer.title);
      } catch (e) {
        if (mounted) _showMessage('Unable to share at this time');
      }
    }
  }

  void _showWebShareDialog(String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Offer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a platform to share this offer',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ShareOption(
                      icon: Icons.phone,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () {
                        Navigator.pop(context);
                        _shareToWhatsApp(text);
                      },
                    ),
                    _ShareOption(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onTap: () {
                        Navigator.pop(context);
                        _shareToFacebook();
                      },
                    ),
                    _ShareOption(
                      icon: Icons.close,
                      label: 'Twitter',
                      color: Colors.black,
                      onTap: () {
                        Navigator.pop(context);
                        _shareToTwitter(text);
                      },
                    ),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
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
      if (mounted) _showMessage('Could not open WhatsApp');
    }
  }

  Future<void> _shareToFacebook() async {
    final url = Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=https://offora.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) _showMessage('Could not open Facebook');
    }
  }

  Future<void> _shareToTwitter(String text) async {
    final encodedText = Uri.encodeComponent(text);
    final url = Uri.parse('https://twitter.com/intent/tweet?text=$encodedText');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) _showMessage('Could not open Twitter');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.darkBlue,
        ),
      );
    } catch (e) {
      if (kDebugMode) print('Could not show message: $e');
    }
  }

  void _showFullScreenImage(List<String> images, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
          onClose: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  ScreenSizeCategory _getScreenSizeCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSizeCategory.mobile;
    if (width < 1024) return ScreenSizeCategory.tablet;
    return ScreenSizeCategory.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSizeCategory(context);
    final offer = widget.offer;
    final images =
        (offer.imageUrls ?? []).where((url) => url.isNotEmpty).toList();

    if (screenSize == ScreenSizeCategory.desktop) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[50],
                child: _buildHeroSection(offer, images),
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
                  child: _buildContentSection(offer, screenSize),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenSize == ScreenSizeCategory.tablet ? 380 : 320,
            flexibleSpace:
                FlexibleSpaceBar(background: _buildHeroSection(offer, images)),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: true,
            pinned: true,
            actions: [
              IconButton(
                onPressed: _toggleCompare,
                tooltip: _isInCompare ? 'Remove from Compare' : 'Compare',
                icon: Icon(
                  _isInCompare ? Icons.check_circle : Icons.compare_arrows,
                  color: _isInCompare ? Colors.green : AppColors.darkBlue,
                ),
              ),
              IconButton(
                onPressed: _toggleSave,
                tooltip: _isSaved ? 'Remove from Saved' : 'Save',
                icon: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isSaved ? Colors.redAccent : AppColors.darkBlue,
                ),
              ),
              IconButton(
                onPressed: _shareOffer,
                tooltip: 'Share',
                icon:
                    const Icon(Icons.share_outlined, color: AppColors.darkBlue),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: screenSize == ScreenSizeCategory.mobile ? 100 : 32,
              ),
              child: _buildContentSection(offer, screenSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Offer offer, List<String> images) {
    final screenSize = _getScreenSizeCategory(context);
    final hasImages = images.isNotEmpty;
    final heroHeight = screenSize == ScreenSizeCategory.desktop
        ? 600.0
        : screenSize == ScreenSizeCategory.tablet
            ? 380.0
            : 320.0;

    return Stack(
      children: [
        GestureDetector(
          onTap: hasImages
              ? () => _showFullScreenImage(images, _currentImageIndex)
              : null,
          child: SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: hasImages
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _buildImagePlaceholder(heroHeight);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder(heroHeight);
                        },
                      );
                    },
                  )
                : _buildImagePlaceholder(heroHeight),
          ),
        ),
        if (hasImages && images.length > 1)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      color: const Color(0xFFF0F4FF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.image_outlined,
              color: AppColors.darkBlue,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(Offer offer, ScreenSizeCategory screenSize) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    double discount = 0;
    double displayDiscountPrice = offer.discountPrice ?? 0;

    if (offer.offerType == OfferType.percentageDiscount) {
      discount = offer.percentageOff ?? 0;
      // Calculate actual discount price based on percentage for percentage discount offers
      if (discount > 0 && offer.originalPrice > 0) {
        displayDiscountPrice = offer.originalPrice * (1 - (discount / 100));
      }
    } else if (offer.offerType == OfferType.flatDiscount) {
      final flatAmount = offer.flatDiscountAmount ?? 0;
      // Calculate actual discount price for flat discount offers
      if (flatAmount > 0 && offer.originalPrice > 0) {
        displayDiscountPrice = offer.originalPrice - flatAmount;
        discount = ((flatAmount / offer.originalPrice) * 100);
      }
    } else if (offer.originalPrice > 0 && offer.discountPrice != null) {
      discount = ((1 - (offer.discountPrice! / offer.originalPrice)) * 100);
    }

    final hasPrice = displayDiscountPrice > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          offer.title,
          style: TextStyle(
            fontSize: screenSize == ScreenSizeCategory.mobile ? 22 : 26,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        if (hasPrice)
          Row(
            children: [
              Text(
                currency.format(displayDiscountPrice.toInt()),
                style: TextStyle(
                  fontSize: screenSize == ScreenSizeCategory.mobile ? 24 : 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkBlue,
                ),
              ),
              if (offer.originalPrice > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    currency.format(offer.originalPrice),
                    style: TextStyle(
                      fontSize:
                          screenSize == ScreenSizeCategory.mobile ? 16 : 18,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${discount.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          )
        else
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${discount.toStringAsFixed(0)}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        if (offer.businessCategory != null ||
            offer.city != null ||
            offer.address != null ||
            (offer.client != null &&
                offer.client!['businessName'] != null)) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Info',
                style: TextStyle(
                  fontSize: screenSize == ScreenSizeCategory.mobile ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (offer.client != null &&
                        offer.client!['businessName'] != null)
                      _InfoRow(
                        label: 'Store',
                        value: offer.client!['businessName'].toString(),
                        screenSize: screenSize,
                        icon: Icons.storefront_outlined,
                      ),
                    if (offer.businessCategory != null &&
                        offer.businessCategory!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      _InfoRow(
                        label: 'Category',
                        value: offer.businessCategory!,
                        screenSize: screenSize,
                        icon: Icons.category_outlined,
                      ),
                    ],
                    if (offer.address != null && offer.address!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      _InfoRow(
                        label: 'Address',
                        value: offer.address!,
                        screenSize: screenSize,
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                    if (offer.city != null && offer.city!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      _InfoRow(
                        label: 'City',
                        value: offer.city!,
                        screenSize: screenSize,
                        icon: Icons.location_city_outlined,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
        if (offer.startDate != null || offer.endDate != null) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Validity Period',
                style: TextStyle(
                  fontSize: screenSize == ScreenSizeCategory.mobile ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFFF0F7FF),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.darkBlue.withAlpha(30), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.darkBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valid From',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer.startDate != null
                                ? dateFormat.format(offer.startDate!)
                                : 'N/A',
                            style: TextStyle(
                              fontSize: screenSize == ScreenSizeCategory.mobile
                                  ? 15
                                  : 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valid Till',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer.endDate != null
                                ? dateFormat.format(offer.endDate!)
                                : 'N/A',
                            style: TextStyle(
                              fontSize: screenSize == ScreenSizeCategory.mobile
                                  ? 15
                                  : 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey[200], thickness: 1),
              const SizedBox(height: 24),
            ],
          ),
        ],
        if (offer.description.isNotEmpty) ...[
          Text(
            'Description',
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            offer.description,
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 14 : 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 24),
        ],
        if (offer.contactNumber != null && offer.contactNumber!.isNotEmpty) ...[
          Text(
            'Contact',
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Phone',
            value: offer.contactNumber!,
            screenSize: screenSize,
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 24),
        ],
        if (offer.applicableProducts != null &&
            offer.applicableProducts!.isNotEmpty) ...[
          Text(
            'Applicable Products',
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: offer.applicableProducts!
                .map(
                  (product) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.darkBlue.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      product,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 24),
        ],
        if (offer.applicableServices != null &&
            offer.applicableServices!.isNotEmpty) ...[
          Text(
            'Applicable Services',
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: offer.applicableServices!
                .map(
                  (service) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.darkBlue.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      service,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 24),
        ],
        if (offer.terms != null && offer.terms!.isNotEmpty) ...[
          Text(
            'Important Information',
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAE6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brightGold, width: 1.5),
            ),
            child: Text(
              offer.terms!,
              style: TextStyle(
                fontSize: screenSize == ScreenSizeCategory.mobile ? 13 : 14,
                color: Colors.grey[800],
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final VoidCallback onClose;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.onClose,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _nextPage();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _previousPage();
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onClose();
            }
          }
        },
        child: Stack(
          children: [
            // Main Image Viewer
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    maxScale: 4.0,
                    minScale: 0.5,
                    child: Center(
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Arrows
            if (widget.images.length > 1) ...[
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _currentIndex > 0 ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 36),
                        onPressed: _currentIndex > 0 ? _previousPage : null,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity:
                        _currentIndex < widget.images.length - 1 ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 36),
                        onPressed: _currentIndex < widget.images.length - 1
                            ? _nextPage
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Top Bar (Close button and index)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(150),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Thumbnail Strip (Desktop/Tablet)
            if (widget.images.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    height: 60,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _currentIndex == index;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withAlpha(50),
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(widget.images[index]),
                                fit: BoxFit.cover,
                                opacity: isSelected ? 1.0 : 0.6,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ScreenSizeCategory screenSize;
  final IconData? icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.screenSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: AppColors.darkBlue.withAlpha(180),
          ),
          const SizedBox(width: 12),
        ],
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 13 : 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: screenSize == ScreenSizeCategory.mobile ? 13 : 14,
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
