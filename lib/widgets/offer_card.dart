import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/compare_service.dart';
import '../services/saved_offers_service.dart';
import '../services/auth_service.dart';
import '../client/models/offer.dart';
import '../core/error_messages.dart';

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

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: AspectRatio(
          aspectRatio: 0.55,
          child: Container(
            width: double.infinity,
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
                final maxH = constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : 240.0;
                final imageHeight = (maxH * 0.48).clamp(80.0, 150.0);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
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
                                            child: const Icon(
                                                Icons.broken_image,
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
                                .isNotEmpty)
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                widget.offer['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Color(0xFF1F477D),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.store_outlined,
                                      size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      widget.offer['store'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Price section with compare button
                              if (originalPrice != null &&
                                  discountPrice != null)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${discountPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1F477D),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${originalPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget.offerData != null)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isInCompare
                                              ? const Color(0xFF1F477D)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                                  duration:
                                                      Duration(seconds: 2),
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
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
