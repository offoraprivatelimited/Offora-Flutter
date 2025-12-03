import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';

import '../client/models/offer.dart';
import '../client/services/offer_service.dart';
import '../widgets/offer_card.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F477D);

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                toolbarHeight: 44,
                automaticallyImplyLeading: false,
                title: Builder(
                  builder: (ctx) => Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF1F477D)),
                        onPressed: () {
                          Scaffold.of(ctx).openDrawer();
                        },
                      ),
                      const SizedBox(width: 8),
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
            ),
            // Removed 'Home' header title for a cleaner top bar
            // Add spacing after AppBar
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            // Search bar removed
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

                    // No search filter
                    final filteredOffers = offers;

                    if (filteredOffers.isEmpty) {
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
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredOffers.length,
                      itemBuilder: (context, i) {
                        final offer = filteredOffers[i];
                        final offerMap = <String, dynamic>{
                          'title': offer.title,
                          'store':
                              offer.client?['businessName'] ?? offer.clientId,
                          'image': offer.imageUrls?.isNotEmpty == true
                              ? offer.imageUrls![0]
                              : 'assets/images/logo/original/Logo_without_text_with_background.jpg',
                          'discount':
                              '${((1 - (offer.discountPrice / offer.originalPrice)) * 100).toStringAsFixed(0)}% OFF',
                        };
                        return OfferCard(
                          offer: offerMap,
                          offerData: offer,
                          onTap: () {
                            // Find MainScreen ancestor and show offer details inline
                            final mainScreenState = context
                                .findAncestorStateOfType<MainScreenState>();
                            if (mainScreenState != null) {
                              mainScreenState.showOfferDetails(offer);
                            }
                          },
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
      ),
    );
  }
}
