// ignore_for_file: prefer_const_constructors

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
import 'main_screen.dart';

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

    // If MainScreen is mounted (via global key), show the offer inline there
    final mainState = MainScreen.globalKey.currentState;
    if (mainState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mainState.showOfferDetails(args);
        // Pop this pushed route since the details are shown inline
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });

      return const Scaffold(
        body: SizedBox.shrink(),
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
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
      if (mounted) {
        _showMessage('Could not open WhatsApp');
      }
    }
  }

  Future<void> _shareToFacebook() async {
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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.darkBlue,
      ),
    );
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
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // Helper method to get current screen size category
  ScreenSizeCategory _getScreenSizeCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSizeCategory.mobile;
    } else if (width < 1024) {
      return ScreenSizeCategory.tablet;
    } else {
      return ScreenSizeCategory.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSizeCategory(context);
    final offer = widget.offer;
    final images =
        (offer.imageUrls ?? []).where((url) => url.isNotEmpty).toList();
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final discount = ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
        .toStringAsFixed(0);

    // For desktop, use a two-column layout
    if (screenSize == ScreenSizeCategory.desktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Image section (fixed width)
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              constraints: const BoxConstraints(maxWidth: 700),
              child: _buildHeroSection(offer, images, currency, discount),
            ),

            // Right column - Content section
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getContentPadding(screenSize),
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildContentSection(offer, screenSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // For mobile and tablet, use scrollable layout
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: CustomScrollView(
        slivers: [
          // App bar with hero section
          SliverAppBar(
            expandedHeight: screenSize == ScreenSizeCategory.tablet ? 380 : 320,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroSection(offer, images, currency, discount),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            pinned: true,
            actions: [
              IconButton(
                onPressed: _toggleCompare,
                tooltip: _isInCompare ? 'Remove from Compare' : 'Compare',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isInCompare ? Icons.check_circle : Icons.compare_arrows,
                    color: _isInCompare ? Colors.green : AppColors.darkBlue,
                    size: 20,
                  ),
                ),
              ),
              IconButton(
                onPressed: _toggleSave,
                tooltip: _isSaved ? 'Remove from Saved' : 'Save',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSaved ? Icons.favorite : Icons.favorite_border,
                    color: _isSaved ? Colors.redAccent : AppColors.darkBlue,
                    size: 20,
                  ),
                ),
              ),
              IconButton(
                onPressed: _shareOffer,
                tooltip: 'Share',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined,
                      color: AppColors.darkBlue, size: 20),
                ),
              ),
            ],
          ),

          // Content section
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getContentPadding(screenSize),
                  ),
                  child: _buildContentSection(offer, screenSize),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Helper method to get appropriate content padding based on screen size
  double _getContentPadding(ScreenSizeCategory screenSize) {
    switch (screenSize) {
      case ScreenSizeCategory.mobile:
        return 16;
      case ScreenSizeCategory.tablet:
        return 32;
      case ScreenSizeCategory.desktop:
        return 48;
    }
  }

  // Helper method to get appropriate font sizes based on screen size
  double _getTitleFontSize(ScreenSizeCategory screenSize) {
    switch (screenSize) {
      case ScreenSizeCategory.mobile:
        return 22;
      case ScreenSizeCategory.tablet:
        return 26;
      case ScreenSizeCategory.desktop:
        return 30;
    }
  }

  double _getPriceFontSize(ScreenSizeCategory screenSize) {
    switch (screenSize) {
      case ScreenSizeCategory.mobile:
        return 28;
      case ScreenSizeCategory.tablet:
        return 32;
      case ScreenSizeCategory.desktop:
        return 36;
    }
  }

  Widget _buildHeroSection(
    Offer offer,
    List<String> images,
    NumberFormat currency,
    String discount,
  ) {
    final screenSize = _getScreenSizeCategory(context);
    final hasImages = images.isNotEmpty;
    final heroHeight =
        (screenSize == ScreenSizeCategory.tablet ? 380.0 : 320.0);

    return Stack(
      children: [
        // Main image
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

        // Gradient overlay
        Container(
          height: heroHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // Back button for desktop
        if (screenSize == ScreenSizeCategory.desktop)
          Positioned(
            top: 32,
            left: 32,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ),

        // Image count indicator
        if (hasImages && images.length > 1)
          Positioned(
            top: screenSize == ScreenSizeCategory.desktop ? 32 : 60,
            right: screenSize == ScreenSizeCategory.desktop ? 32 : 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
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

        // View full screen button
        if (hasImages && screenSize != ScreenSizeCategory.desktop)
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _showFullScreenImage(images, _currentImageIndex),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fullscreen,
                      color: AppColors.darkBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'View Full',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // For desktop, show title and price over the image
        if (screenSize == ScreenSizeCategory.desktop)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: TextStyle(
                      fontSize: _getTitleFontSize(screenSize),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        currency.format(offer.discountPrice),
                        style: TextStyle(
                          fontSize: _getPriceFontSize(screenSize),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        currency.format(offer.originalPrice),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
          children: [
            Icon(
              Icons.image_outlined,
              color: AppColors.darkBlue,
              size: 48,
            ),
            const SizedBox(height: 8),
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
    final discount = ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
        .toStringAsFixed(0);

    return Column(
      children: [
        // Main content card
        Container(
          margin: screenSize == ScreenSizeCategory.mobile
              ? const EdgeInsets.only(top: 16, bottom: 16)
              : const EdgeInsets.only(top: 32, bottom: 32),
          padding: screenSize == ScreenSizeCategory.mobile
              ? const EdgeInsets.all(20)
              : const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // For mobile/tablet, show title and price here
              if (screenSize != ScreenSizeCategory.desktop) ...[
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: _getTitleFontSize(screenSize),
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlue,
                        letterSpacing: -0.3,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 16),

                // Price row
                Row(
                  children: [
                    // Price to the left
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.format(offer.discountPrice),
                          style: TextStyle(
                            fontSize: _getPriceFontSize(screenSize),
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBlue,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Was ${currency.format(offer.originalPrice)}',
                          style: TextStyle(
                            fontSize: screenSize == ScreenSizeCategory.mobile
                                ? 14
                                : 16,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Discount badge to the right
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            screenSize == ScreenSizeCategory.mobile ? 12 : 16,
                        vertical:
                            screenSize == ScreenSizeCategory.mobile ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize:
                              screenSize == ScreenSizeCategory.mobile ? 14 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons for desktop
              if (screenSize == ScreenSizeCategory.desktop)
                _buildDesktopActionButtons(),

              SizedBox(
                  height: screenSize == ScreenSizeCategory.desktop ? 16 : 32),

              // Highlights
              _buildHighlights(offer, screenSize),
              const SizedBox(height: 32),

              // Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.darkBlue,
                        size: screenSize == ScreenSizeCategory.mobile ? 20 : 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlue,
                              fontSize: screenSize == ScreenSizeCategory.mobile
                                  ? 18
                                  : 22,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offer.description,
                    style: TextStyle(
                      fontSize:
                          screenSize == ScreenSizeCategory.mobile ? 15 : 16,
                      color: Colors.grey.shade700,
                      height: 1.7,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Business Information
              if (offer.client != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          color: AppColors.darkBlue,
                          size:
                              screenSize == ScreenSizeCategory.mobile ? 20 : 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Business Information',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlue,
                                    fontSize:
                                        screenSize == ScreenSizeCategory.mobile
                                            ? 18
                                            : 22,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.store_outlined,
                            label: 'Business Name',
                            value: offer.client!['businessName'] ?? 'N/A',
                            screenSize: screenSize,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: offer.client!['email'] ?? 'N/A',
                            screenSize: screenSize,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: offer.client!['phoneNumber'] ?? 'N/A',
                            screenSize: screenSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // Timeline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        color: AppColors.darkBlue,
                        size: screenSize == ScreenSizeCategory.mobile ? 20 : 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Timeline',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlue,
                              fontSize: screenSize == ScreenSizeCategory.mobile
                                  ? 18
                                  : 22,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (offer.createdAt != null)
                          _InfoRow(
                            icon: Icons.create_outlined,
                            label: 'Created',
                            value: DateFormat('MMM d, yyyy • hh:mm a')
                                .format(offer.createdAt!),
                            screenSize: screenSize,
                          ),
                        if (offer.updatedAt != null) ...[
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.update_outlined,
                            label: 'Last Updated',
                            value: DateFormat('MMM d, yyyy • hh:mm a')
                                .format(offer.updatedAt!),
                            screenSize: screenSize,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Validity
              if (offer.startDate != null || offer.endDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.darkBlue,
                          size:
                              screenSize == ScreenSizeCategory.mobile ? 20 : 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Offer Validity',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlue,
                                    fontSize:
                                        screenSize == ScreenSizeCategory.mobile
                                            ? 18
                                            : 22,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (offer.startDate != null)
                            _InfoRow(
                              icon: Icons.play_circle_outline,
                              label: 'Starts',
                              value: DateFormat('MMM d, yyyy')
                                  .format(offer.startDate!),
                              screenSize: screenSize,
                            ),
                          if (offer.endDate != null) ...[
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.stop_circle_outlined,
                              label: 'Ends',
                              value: DateFormat('MMM d, yyyy')
                                  .format(offer.endDate!),
                              screenSize: screenSize,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Terms & Conditions
              if (offer.terms != null && offer.terms!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gavel_outlined,
                          color: AppColors.darkBlue,
                          size:
                              screenSize == ScreenSizeCategory.mobile ? 20 : 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Terms & Conditions',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlue,
                                    fontSize:
                                        screenSize == ScreenSizeCategory.mobile
                                            ? 18
                                            : 22,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        offer.terms!,
                        style: TextStyle(
                          fontSize:
                              screenSize == ScreenSizeCategory.mobile ? 14 : 16,
                          color: Colors.grey.shade700,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _DesktopActionButton(
            icon: _isInCompare ? Icons.check_circle : Icons.compare_arrows,
            label: _isInCompare ? 'In Compare' : 'Compare',
            isActive: _isInCompare,
            onTap: _toggleCompare,
          ),
          _DesktopActionButton(
            icon: _isSaved ? Icons.favorite : Icons.favorite_border,
            label: _isSaved ? 'Saved' : 'Save',
            isActive: _isSaved,
            onTap: _toggleSave,
          ),
          _DesktopActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: _shareOffer,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(Offer offer, ScreenSizeCategory screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star_outline,
              color: AppColors.darkBlue,
              size: screenSize == ScreenSizeCategory.mobile ? 20 : 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Key Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                    fontSize: screenSize == ScreenSizeCategory.mobile ? 18 : 22,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: screenSize == ScreenSizeCategory.mobile ? 12 : 16,
          runSpacing: screenSize == ScreenSizeCategory.mobile ? 12 : 16,
          children: [
            _FeatureChip(
              icon: Icons.local_offer_outlined,
              label: 'Type',
              value: _formatOfferType(offer.offerType),
              screenSize: screenSize,
            ),
            _FeatureChip(
              icon: Icons.category_outlined,
              label: 'Category',
              value: _formatOfferCategory(offer.offerCategory),
              screenSize: screenSize,
            ),
            if (offer.minimumPurchase != null)
              _FeatureChip(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Min Spend',
                value: '₹${offer.minimumPurchase!.toStringAsFixed(0)}',
                screenSize: screenSize,
              ),
            if (offer.maxUsagePerCustomer != null)
              _FeatureChip(
                icon: Icons.repeat_one_outlined,
                label: 'Per Customer',
                value: '${offer.maxUsagePerCustomer} uses',
                screenSize: screenSize,
              ),
          ],
        ),
      ],
    );
  }

  String _formatOfferType(OfferType type) {
    switch (type) {
      case OfferType.percentageDiscount:
        return 'Percent Off';
      case OfferType.flatDiscount:
        return 'Flat Discount';
      case OfferType.buyXGetYPercentOff:
        return 'Buy X Get Y%';
      case OfferType.buyXGetYRupeesOff:
        return 'Buy X Get ₹Y';
      case OfferType.bogo:
        return 'BOGO';
      case OfferType.productSpecific:
        return 'Product Specific';
      case OfferType.serviceSpecific:
        return 'Service Specific';
      case OfferType.bundleDeal:
        return 'Bundle Deal';
    }
  }

  String _formatOfferCategory(OfferCategory category) {
    switch (category) {
      case OfferCategory.product:
        return 'Product';
      case OfferCategory.service:
        return 'Service';
      case OfferCategory.both:
        return 'Product & Service';
    }
  }
}

// Full Screen Image Viewer
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
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
                  if (widget.images.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(widget.images.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding: EdgeInsets.all(
                                    _currentIndex == index ? 2 : 0),
                                decoration: BoxDecoration(
                                  border: _currentIndex == index
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    widget.images[index],
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
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

// Info row widget for business info, timeline, etc.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ScreenSizeCategory screenSize;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              EdgeInsets.all(screenSize == ScreenSizeCategory.mobile ? 8 : 10),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: screenSize == ScreenSizeCategory.mobile ? 18 : 20,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenSize == ScreenSizeCategory.mobile ? 12 : 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: screenSize == ScreenSizeCategory.mobile ? 14 : 16,
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Feature chip for highlights section
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ScreenSizeCategory screenSize;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize == ScreenSizeCategory.mobile ? 16 : 20,
        vertical: screenSize == ScreenSizeCategory.mobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: screenSize == ScreenSizeCategory.mobile ? 18 : 20,
            color: AppColors.darkBlue,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenSize == ScreenSizeCategory.mobile ? 11 : 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: screenSize == ScreenSizeCategory.mobile ? 14 : 16,
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

// Desktop action button
class _DesktopActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DesktopActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? AppColors.paleBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.darkBlue : Colors.grey.shade700,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.darkBlue : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
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
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

// Screen size category enum
enum ScreenSizeCategory {
  mobile,
  tablet,
  desktop,
}
