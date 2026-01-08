import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/services/compare_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../client/models/offer.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compareService = Provider.of<CompareService>(context);
    final comparedOffers = compareService.comparedOffers;

    return SafeArea(
      child: comparedOffers.isEmpty
          ? const EmptyState(
              icon: Icons.compare_arrows,
              title: 'No offers to compare',
              message: 'Browse offers and add them to comparison',
            )
          : Column(
              children: [
                _buildHeader(context, compareService, comparedOffers.length),
                Expanded(
                  child: _buildComparisonView(
                      context, comparedOffers, compareService),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(
      BuildContext context, CompareService compareService, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compare Offers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count of 4 offers selected',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => compareService.clearCompare(),
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(
      BuildContext context, List<Offer> offers, CompareService compareService) {
    // Layout: 2 columns for 1-2 offers, 2x2 grid for 3-4 offers
    final needsGrid = offers.length > 2;

    if (needsGrid) {
      return _buildGridComparison(context, offers, compareService);
    } else {
      return _buildRowComparison(context, offers, compareService);
    }
  }

  Widget _buildRowComparison(
      BuildContext context, List<Offer> offers, CompareService compareService) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: offers.map((offer) {
          return Expanded(
            child: _buildOfferColumn(context, offer, compareService),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridComparison(
      BuildContext context, List<Offer> offers, CompareService compareService) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // First row (2 offers)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildOfferColumn(context, offers[0], compareService),
                ),
                Expanded(
                  child: _buildOfferColumn(context, offers[1], compareService),
                ),
              ],
            ),
          ),
          // Second row (remaining offers)
          if (offers.length > 2)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        _buildOfferColumn(context, offers[2], compareService),
                  ),
                  if (offers.length > 3)
                    Expanded(
                      child:
                          _buildOfferColumn(context, offers[3], compareService),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfferColumn(
      BuildContext context, Offer offer, CompareService compareService) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final discount = offer.discountPrice != null
        ? ((1 - (offer.discountPrice! / offer.originalPrice)) * 100)
            .toStringAsFixed(0)
        : '0';
    final hasImage = offer.imageUrls?.isNotEmpty == true;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with remove button
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: hasImage
                      ? Image.network(
                          offer.imageUrls!.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => compareService.removeFromCompare(offer.id),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close, size: 18, color: Colors.black87),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brightGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$discount% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price
                _buildCompareRow(
                  'Price',
                  currency.format(offer.discountPrice),
                  highlight: true,
                ),
                const SizedBox(height: 6),
                _buildCompareRow(
                  'Original',
                  currency.format(offer.originalPrice),
                  strikethrough: true,
                ),
                const SizedBox(height: 6),
                _buildCompareRow(
                  'Savings',
                  currency
                      .format(offer.originalPrice - (offer.discountPrice ?? 0)),
                  color: Colors.green.shade700,
                ),

                const Divider(height: 20),

                // Type
                _buildCompareRow(
                  'Type',
                  _formatOfferType(offer.offerType),
                ),
                const SizedBox(height: 6),

                // Category
                _buildCompareRow(
                  'Category',
                  _formatOfferCategory(offer.offerCategory),
                ),
                const SizedBox(height: 6),

                // Min Purchase
                if (offer.minimumPurchase != null) ...[
                  _buildCompareRow(
                    'Min Spend',
                    '₹${offer.minimumPurchase!.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 6),
                ],

                // Max Usage
                if (offer.maxUsagePerCustomer != null) ...[
                  _buildCompareRow(
                    'Max Uses',
                    '${offer.maxUsagePerCustomer}x per customer',
                  ),
                  const SizedBox(height: 6),
                ],

                // Validity
                if (offer.startDate != null || offer.endDate != null) ...[
                  const Divider(height: 20),
                  if (offer.startDate != null) ...[
                    _buildCompareRow(
                      'Starts',
                      DateFormat('MMM d, yyyy').format(offer.startDate!),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (offer.endDate != null) ...[
                    _buildCompareRow(
                      'Ends',
                      DateFormat('MMM d, yyyy').format(offer.endDate!),
                    ),
                  ],
                ],

                const SizedBox(height: 12),

                // Description
                Text(
                  offer.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
          size: 32,
        ),
      ),
    );
  }

  Widget _buildCompareRow(
    String label,
    String value, {
    bool highlight = false,
    bool strikethrough = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 16 : 12,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w700,
              color: color ??
                  (highlight ? AppColors.darkBlue : AppColors.darkBlue),
              decoration: strikethrough ? TextDecoration.lineThrough : null,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        return 'BOGO';
      case OfferType.productSpecific:
        return 'Product';
      case OfferType.serviceSpecific:
        return 'Service';
      case OfferType.bundleDeal:
        return 'Bundle';
    }
  }

  String _formatOfferCategory(OfferCategory category) {
    switch (category) {
      case OfferCategory.product:
        return 'Products';
      case OfferCategory.service:
        return 'Services';
      case OfferCategory.both:
        return 'Both';
    }
  }
}
