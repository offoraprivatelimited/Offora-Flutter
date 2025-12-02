import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../services/compare_service.dart';
import '../widgets/empty_state.dart';
import '../client/models/offer.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compareService = Provider.of<CompareService>(context);
    final comparedOffers = compareService.comparedOffers;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              toolbarHeight: 44,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  SizedBox(
                    height: 28,
                    child: Image.asset(
                      'assets/images/logo/original/Text_without_logo_without_background.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Compare',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  if (comparedOffers.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => compareService.clearCompare(),
                      icon: const Icon(Icons.clear_all,
                          color: Colors.black54, size: 18),
                      label: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (comparedOffers.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.compare_arrows,
                title: 'No offers to compare',
                message: 'Browse offers and add them to comparison',
              ),
            )
          else
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comparedOffers
                      .map((offer) => _CompareCard(
                            offer: offer,
                            onRemove: () =>
                                compareService.removeFromCompare(offer.id),
                          ))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onRemove;

  const _CompareCard({
    required this.offer,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹');
    final discount = ((1 - (offer.discountPrice / offer.originalPrice)) * 100)
        .toStringAsFixed(0);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBlue.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: offer.imageUrls?.isNotEmpty == true
                    ? Image.network(
                        offer.imageUrls![0],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PlaceholderImage(),
                      )
                    : _PlaceholderImage(),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withAlpha(128),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brightGold, AppColors.darkerGold],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$discount% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.store, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        offer.client?['businessName'] ?? 'Store',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Price Comparison
                _CompareRow(
                  label: 'Original Price',
                  value: currency.format(offer.originalPrice),
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                _CompareRow(
                  label: 'Offer Price',
                  value: currency.format(offer.discountPrice),
                  color: AppColors.brightGold,
                  isHighlight: true,
                ),
                const SizedBox(height: 8),
                _CompareRow(
                  label: 'You Save',
                  value: currency
                      .format(offer.originalPrice - offer.discountPrice),
                  color: Colors.green.shade700,
                  isHighlight: true,
                ),

                if (offer.startDate != null || offer.endDate != null) ...[
                  const Divider(height: 24),
                  if (offer.startDate != null)
                    _CompareRow(
                      label: 'Valid From',
                      value: DateFormat('MMM d, yyyy').format(offer.startDate!),
                      color: Colors.grey.shade600,
                    ),
                  if (offer.endDate != null) ...[
                    const SizedBox(height: 8),
                    _CompareRow(
                      label: 'Valid Until',
                      value: DateFormat('MMM d, yyyy').format(offer.endDate!),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image,
        size: 64,
        color: Colors.grey.shade400,
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isHighlight;

  const _CompareRow({
    required this.label,
    required this.value,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            fontSize: isHighlight ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
