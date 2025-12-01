import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/offer_card.dart';
import '../client/models/offer.dart';
import '../client/services/offer_service.dart';
import 'offer_details_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Premium header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      darkBlue,
                      darkBlue.withAlpha(85),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Image.asset(
                        'images/logo/original/Text_without_logo_without_background.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore all offers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSearchBar(onChanged: (v) {}, onTapFilter: () {}),
            ),
          ),
          // Offers grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverFillRemaining(
              child: StreamBuilder<List<Offer>>(
                stream: context.read<OfferService>().watchApprovedOffers(),
                builder: (context, snapshot) {
                  // Show loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: darkBlue,
                      ),
                    );
                  }

                  // Handle errors
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Error loading offers: ${snapshot.error}'),
                      ),
                    );
                  }

                  // Get offers list
                  final offers = snapshot.data ?? [];

                  // Show empty state if no offers
                  if (offers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 64, color: darkBlue.withAlpha(20)),
                            const SizedBox(height: 16),
                            Text(
                              'No offers available yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: darkBlue,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back soon for amazing deals!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Display offers in grid
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: offers.length,
                    itemBuilder: (context, i) {
                      final offer = offers[i];
                      // Convert Offer to Map for OfferCard compatibility
                      final offerMap = <String, dynamic>{
                        'title': offer.title,
                        'store':
                            offer.client?['businessName'] ?? offer.clientId,
                        'image': offer.imageUrls?.isNotEmpty == true
                            ? offer.imageUrls![0]
                            : 'assets/images/placeholder.png',
                        'discount':
                            '${((1 - (offer.discountPrice / offer.originalPrice)) * 100).toStringAsFixed(0)}%',
                      };
                      return OfferCard(
                        offer: offerMap,
                        onTap: () => Navigator.pushNamed(
                          context,
                          OfferDetailsScreen.routeName,
                          arguments: offer,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
