import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../services/saved_offers_service.dart';
import '../widgets/offer_card.dart';
import '../widgets/empty_state.dart';
import '../client/models/offer.dart';
import 'main_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.bookmark_border,
            title: 'Sign in required',
            message: 'Please sign in to view your saved offers',
          ),
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          FutureBuilder<List<Offer>>(
            future: context.read<SavedOffersService>().getSavedOffers(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkBlue,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Oops!',
                    message: 'Could not load saved offers. Please try again.',
                  ),
                );
              }

              final savedOffers = snapshot.data ?? [];

              if (savedOffers.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.bookmark_border,
                    title: 'No saved offers yet',
                    message:
                        'Start saving your favorite offers to find them here',
                  ),
                );
              }

              return SliverPadding(
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
                      final offer = savedOffers[index];
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
                    childCount: savedOffers.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
