import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/compare_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/offer_card.dart';

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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final offer = comparedOffers[index];
                    final offerMap = <String, dynamic>{
                      'title': offer.title,
                      'store': offer.client?['businessName'] ?? offer.clientId,
                      'discount':
                          '${((1 - (offer.discountPrice / offer.originalPrice)) * 100).toStringAsFixed(0)}% OFF',
                    };
                    return OfferCard(
                      offer: offerMap,
                      offerData: offer,
                      onTap: () {
                        // Navigate to offer details or show inline
                      },
                    );
                  },
                  childCount: comparedOffers.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
