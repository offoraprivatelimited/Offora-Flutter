import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/compare_service.dart';
import '../services/saved_offers_service.dart';
import '../services/auth_service.dart';
import '../client/models/offer.dart';

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
        SnackBar(content: Text('Failed to update saved status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final compareService = context.watch<CompareService>();
    final isInCompare = widget.offerData != null &&
        compareService.isInCompare(widget.offerData!.id);

    // Extract prices if available
    final originalPrice = widget.offerData?.originalPrice;
    final discountPrice = widget.offerData?.discountPrice;

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF8F9FB),
                const Color(0xFFE9EDF5),
                const Color(0xFFF0B84D).withAlpha(10),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFF0B84D).withAlpha(46),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFFF0B84D).withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Discount badge
                      if ((widget.offer['discount'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF0B84D), Color(0xFFE5A037)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF0B84D).withAlpha(56),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.offer['discount'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF1F477D),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),

                      // Title
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

                      // Store name
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

                      const Spacer(),

                      // Price section
                      if (originalPrice != null && discountPrice != null) ...[
                        Divider(
                            height: 16,
                            thickness: 1,
                            color: const Color(0xFFF0B84D).withAlpha(13)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹${discountPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1F477D),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '₹${originalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Save ₹${(originalPrice - discountPrice).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Overlay action buttons (only if offerData provided)
                if (widget.offerData != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        Container(
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
                              _isSaved ? Icons.favorite : Icons.favorite_border,
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
                        const SizedBox(height: 8),
                        Container(
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
                              isInCompare
                                  ? Icons.compare_arrows
                                  : Icons.compare_arrows_outlined,
                              color: isInCompare
                                  ? const Color(0xFF1F477D)
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: () {
                              if (!compareService.isFull || isInCompare) {
                                compareService.toggleCompare(widget.offerData!);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('You can compare up to 4 offers'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
