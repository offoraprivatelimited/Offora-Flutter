import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../widgets/offer_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/sort_filter_bar.dart';
import '../client/models/offer.dart';
import '../client/services/offer_service.dart';
import 'main_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  String? _selectedCity;
  String _sortBy = 'newest'; // newest, discount, price
  final TextEditingController _searchController = TextEditingController();

  List<Offer> _filterOffers(List<Offer> offers) {
    var filtered = offers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((offer) {
        final searchableText =
            '${offer.title} ${offer.description} ${offer.client?['businessName'] ?? ''} ${offer.city ?? ''} ${offer.client?['location'] ?? ''}'
                .toLowerCase();
        return searchableText.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedCity != null && _selectedCity != 'All Cities') {
      filtered = filtered.where((offer) {
        final offerCity = offer.city ?? '';
        return offerCity.toLowerCase() == _selectedCity!.toLowerCase();
      }).toList();
    }

    switch (_sortBy) {
      case 'discount':
        filtered.sort((a, b) {
          final discountA = (1 - (a.discountPrice / a.originalPrice)) * 100;
          final discountB = (1 - (b.discountPrice / b.originalPrice)) * 100;
          return discountB.compareTo(discountA);
        });
        break;
      case 'price':
        filtered.sort((a, b) => a.discountPrice.compareTo(b.discountPrice));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        // Prevent layout jumps on keyboard open/close (esp. web)
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Explore',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // Sort and Filter Bar
          SliverToBoxAdapter(
            child: StreamBuilder<List<Offer>>(
              stream: context.read<OfferService>().watchApprovedOffers(),
              builder: (context, snapshot) {
                final allOffers = snapshot.data ?? [];
                final cities = <String>{};
                for (final offer in allOffers) {
                  if (offer.city != null && offer.city!.isNotEmpty) {
                    cities.add(offer.city!);
                  }
                }
                final sortedCities = cities.toList()..sort();

                return SortFilterBar(
                  currentSortBy: _sortBy,
                  selectedCity: _selectedCity,
                  onSortChanged: (value) {
                    setState(() => _sortBy = value);
                  },
                  onCategoryChanged: (value) {},
                  onCityChanged: (value) {
                    setState(() => _selectedCity = value);
                  },
                  availableCities: sortedCities,
                );
              },
            ),
          ),

          StreamBuilder<List<Offer>>(
            stream: context.read<OfferService>().watchApprovedOffers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.darkBlue),
                  ),
                );
              }

              final allOffers = snapshot.data ?? [];
              final filteredOffers = _filterOffers(allOffers);

              if (filteredOffers.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: 'No offers found',
                    message: 'Try adjusting your search or location filters',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final offer = filteredOffers[index];
                      final offerMap = <String, dynamic>{
                        'title': offer.title,
                        'store':
                            offer.client?['businessName'] ?? offer.clientId,
                        'image': offer.imageUrls?.isNotEmpty == true
                            ? offer.imageUrls![0]
                            : '',
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
                    childCount: filteredOffers.length,
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
