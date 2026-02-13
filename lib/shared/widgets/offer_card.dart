import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/compare_service.dart';
import '../services/saved_offers_service.dart';
import '../services/auth_service.dart';
import '../../features/client/models/offer.dart';
import '../../core/errors/error_messages.dart';

class OfferCard extends StatefulWidget {
  final Map<String, dynamic> offer;
  final VoidCallback? onTap;
  final Offer? offerData; // Full offer object for save/compare

  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.offerData,
  });

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool _isSaved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedStatus();
  }

  Future<void> _loadSavedStatus() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null || widget.offerData == null) return;
    final savedService = context.read<SavedOffersService>();
    final saved =
        await savedService.isOfferSaved(currentUser.uid, widget.offerData!.id);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSaveStatus() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null || widget.offerData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save offers')),
      );
      return;
    }

    try {
      final savedService = context.read<SavedOffersService>();
      final newStatus = await savedService.toggleSaveOffer(
          currentUser.uid, widget.offerData!);
      if (mounted) setState(() => _isSaved = newStatus);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorMessages.friendlyErrorMessage(e))),
      );
    }
  }

  String _getDiscountText() {
    if (widget.offerData == null) return '';

    final offer = widget.offerData!;
    String discountText = '0% OFF';

    if (offer.offerType == OfferType.percentageDiscount) {
      final percentage = offer.percentageOff ?? 0;
      discountText = '${percentage.toStringAsFixed(0)}% OFF';
    } else if (offer.offerType == OfferType.flatDiscount) {
      final amount = offer.flatDiscountAmount ?? 0;
      discountText = '₹${amount.toStringAsFixed(0)} OFF';
    } else if (offer.offerType == OfferType.buyXGetYPercentOff) {
      final buyQty = offer.buyQuantity ?? 1;
      final getQty = offer.getQuantity ?? 1;
      final percentage = offer.getPercentage ?? 0;
      discountText =
          'Buy $buyQty Get $getQty ${percentage.toStringAsFixed(0)}%';
    } else if (offer.offerType == OfferType.buyXGetYRupeesOff) {
      final buyQty = offer.buyQuantity ?? 1;
      final getQty = offer.getQuantity ?? 1;
      final amount = offer.getRupees ?? 0;
      discountText = 'Buy $buyQty Get $getQty ₹${amount.toStringAsFixed(0)}';
    } else if (offer.offerType == OfferType.bogo) {
      discountText = 'BOGO';
    } else if (offer.offerType == OfferType.productSpecific) {
      discountText = 'DEAL';
    } else if (offer.offerType == OfferType.serviceSpecific) {
      discountText = 'DEAL';
    } else if (offer.offerType == OfferType.bundleDeal) {
      discountText = 'BUNDLE';
    } else if (offer.discountPrice != null && offer.originalPrice > 0) {
      discountText =
          '${((1 - (offer.discountPrice! / offer.originalPrice)) * 100).toStringAsFixed(0)}% OFF';
    }

    return discountText;
  }

  @override
  Widget build(BuildContext context) {
    final compareService = context.watch<CompareService>();
    final isInCompare = widget.offerData != null &&
        compareService.isInCompare(widget.offerData!.id);

    // Choose image from offerData first, then fallback to mapped field
    final String? imageUrl = (widget.offerData?.imageUrls?.isNotEmpty ?? false)
        ? widget.offerData!.imageUrls!.first
        : (widget.offer['image'] as String?);
    final String displayImageUrl = imageUrl ?? '';
    final bool hasImage = displayImageUrl.isNotEmpty;
    final bool isNetworkImage = displayImageUrl.startsWith('http');

    // Extract prices if available
    final originalPrice = widget.offerData?.originalPrice;
    final discountPrice = widget.offerData?.discountPrice;

    // Calculate correct discount price based on offer type
    double displayDiscountPrice = discountPrice ?? 0;
    if (widget.offerData != null &&
        originalPrice != null &&
        originalPrice > 0) {
      if (widget.offerData!.offerType == OfferType.percentageDiscount) {
        final percentOff = widget.offerData?.percentageOff ?? 0;
        if (percentOff > 0) {
          displayDiscountPrice = originalPrice * (1 - (percentOff / 100));
        }
      } else if (widget.offerData!.offerType == OfferType.flatDiscount) {
        final flatAmount = widget.offerData?.flatDiscountAmount ?? 0;
        if (flatAmount > 0) {
          displayDiscountPrice = originalPrice - flatAmount;
        }
      }
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Container(
          width: double.infinity,
          height: 240.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF1F477D).withAlpha(15),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const imageHeight = 155.0;

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image with overlays
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: hasImage
                                ? (isNetworkImage
                                    ? Image.network(
                                        displayImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image,
                                              size: 40),
                                        ),
                                      )
                                    : Image.asset(
                                        displayImageUrl,
                                        fit: BoxFit.cover,
                                      ))
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_outlined,
                                        size: 40, color: Colors.grey),
                                  ),
                          ),
                          // Discount badge
                          if ((widget.offer['discount'] ?? '')
                                  .toString()
                                  .isNotEmpty &&
                              (widget.offer['discount'] ?? '').toString() !=
                                  '0%' &&
                              (widget.offer['discount'] ?? '').toString() !=
                                  '0')
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0B84D),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.offer['discount'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          // Save button
                          if (widget.offerData != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isSaved
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isSaved
                                        ? const Color(0xFFF0B84D)
                                        : Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: _toggleSaveStatus,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Details
                    Container(
                      height: 75.0,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            widget.offer['title'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF1F477D),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Price section or discount badge
                          if (widget.offerData != null &&
                              displayDiscountPrice > 0 &&
                              originalPrice != null &&
                              originalPrice > 0)
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${displayDiscountPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1F477D),
                                            letterSpacing: -0.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '₹${originalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (widget.offerData != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isInCompare
                                            ? const Color(0xFF1F477D)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF1F477D),
                                          width: 1.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(12),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isInCompare
                                              ? Icons.done
                                              : Icons.compare_arrows_outlined,
                                          color: isInCompare
                                              ? Colors.white
                                              : const Color(0xFF1F477D),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          if (!compareService.isFull ||
                                              isInCompare) {
                                            compareService.toggleCompare(
                                                widget.offerData!);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'You can compare up to 4 offers'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        padding: const EdgeInsets.all(10),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.offer['discount'] ??
                                          _getDiscountText(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F477D),
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.offerData != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isInCompare
                                            ? const Color(0xFF1F477D)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF1F477D),
                                          width: 1.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(12),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isInCompare
                                              ? Icons.done
                                              : Icons.compare_arrows_outlined,
                                          color: isInCompare
                                              ? Colors.white
                                              : const Color(0xFF1F477D),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          if (!compareService.isFull ||
                                              isInCompare) {
                                            compareService.toggleCompare(
                                                widget.offerData!);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'You can compare up to 4 offers'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        padding: const EdgeInsets.all(10),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
