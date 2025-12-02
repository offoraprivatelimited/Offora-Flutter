import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/compare_service.dart';
import '../services/saved_offers_service.dart';
import '../services/auth_service.dart';
import '../client/models/offer.dart';

class OfferCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final compareService = context.watch<CompareService>();
    final savedService = context.watch<SavedOffersService>();
    final currentUser = context.watch<AuthService>().currentUser;
    final currentUid = currentUser?.uid;

    final isInCompare =
        offerData != null && compareService.isInCompare(offerData!.id);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 212),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _buildImage(offer['image'] as String?),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              offer['title'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  offer['store'] ?? '',
                                  style: TextStyle(color: Colors.grey[700]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6A11CB),
                                      Color(0xFF2575FC)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  offer['discount'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
              ),

              // Overlay action buttons (only if offerData provided)
              if (offerData != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      // Save button (async state)
                      FutureBuilder<bool>(
                        future: currentUid != null
                            ? savedService.isOfferSaved(
                                currentUid, offerData!.id)
                            : Future.value(false),
                        builder: (context, snap) {
                          final isSavedNow = snap.data ?? false;
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                isSavedNow
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isSavedNow
                                    ? const Color(0xFFF0B84D)
                                    : Colors.grey[700],
                                size: 20,
                              ),
                              onPressed: () async {
                                if (currentUid == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Sign in to save offers')),
                                  );
                                  return;
                                }

                                try {
                                  await savedService.toggleSaveOffer(
                                      currentUid, offerData!);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to update saved status: $e')),
                                  );
                                }
                              },
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 4),

                      // Compare button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
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
                                : Colors.grey[700],
                            size: 20,
                          ),
                          onPressed: () {
                            if (!compareService.isFull || isInCompare) {
                              compareService.toggleCompare(offerData!);
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
    );
  }

  /// Helper to build image from either network URL or asset path
  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        height: 140,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, size: 48)),
      );
    }

    // Check if it's a network URL (Firebase Storage URL)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 140,
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.image, size: 48)),
        ),
      );
    }

    // Otherwise treat as asset path
    return Image.asset(
      imagePath,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 140,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, size: 48)),
      ),
    );
  }
}
