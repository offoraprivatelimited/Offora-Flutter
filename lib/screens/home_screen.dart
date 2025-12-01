import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../client/models/offer.dart';
import '../client/services/offer_service.dart';
import '../widgets/offer_card.dart';
import '../widgets/search_bar.dart';
import 'offer_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Premium header (smaller)
          SliverAppBar(
            expandedHeight: 96,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkBlue,
                      AppColors.darkBlue.withAlpha(200),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Image.asset(
                        'images/logo/original/Text_without_logo_without_background.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Find amazing deals near you',
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
              child: AppSearchBar(
                onChanged: (v) {},
                onTapFilter: () {},
              ),
            ),
          ),
          // Approved offers section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Offers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: darkBlue,
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Offers grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: StreamBuilder<List<Offer>>(
                stream: context.read<OfferService>().watchApprovedOffers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: CircularProgressIndicator(
                          color: darkBlue,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  }

                  final offers = snapshot.data ?? [];

                  if (offers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: darkBlue.withAlpha(51),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No offers available yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: darkBlue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back soon for amazing deals!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
