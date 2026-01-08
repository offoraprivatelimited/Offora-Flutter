import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/offer_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/sort_filter_bar.dart';
import '../../../core/utils/keyboard_utils.dart';
import '../../client/models/offer.dart';
import '../../client/services/offer_service.dart';
import 'main_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  String? _selectedCity;
  String? _selectedCategory;
  String _sortBy = 'newest'; // newest, discount, price
  final TextEditingController _searchController = TextEditingController();

  List<Offer> _filterOffers(List<Offer> offers) {
    var filtered = offers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((offer) {
        final searchLower = _searchQuery.toLowerCase();

        // Build comprehensive searchable text from all available fields
        final client = offer.client;
        final searchableFields = [
          offer.title,
          offer.description,
          offer.address ?? '',
          offer.city ?? '',
          offer.businessCategory ?? '',
          offer.contactNumber ?? '',
          offer.terms ?? '',
          offer.offerType.name,
          offer.offerCategory.name,
          // Client data
          client?['businessName'] ?? '',
          client?['email'] ?? '',
          client?['phoneNumber'] ?? '',
          client?['location'] ?? '',
          client?['contactPerson'] ?? '',
          client?['address'] ?? '',
        ];

        final searchableText = searchableFields.join(' ').toLowerCase();

        // Check if search query matches any field
        if (searchableText.contains(searchLower)) {
          return true;
        }

        // Check if search query matches any keyword
        if (offer.keywords != null && offer.keywords!.isNotEmpty) {
          for (final keyword in offer.keywords!) {
            if (keyword.toLowerCase().contains(searchLower) ||
                searchLower.contains(keyword.toLowerCase())) {
              return true;
            }
          }
        }

        // Check applicable products
        if (offer.applicableProducts != null) {
          for (final product in offer.applicableProducts!) {
            if (product.toLowerCase().contains(searchLower)) {
              return true;
            }
          }
        }

        // Check applicable services
        if (offer.applicableServices != null) {
          for (final service in offer.applicableServices!) {
            if (service.toLowerCase().contains(searchLower)) {
              return true;
            }
          }
        }

        return false;
      }).toList();
    }

    if (_selectedCity != null && _selectedCity != 'All Cities') {
      filtered = filtered.where((offer) {
        final offerCity = offer.city ?? '';
        return offerCity.toLowerCase() == _selectedCity!.toLowerCase();
      }).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((offer) {
        final offerCategory = offer.businessCategory ?? '';
        return offerCategory.toLowerCase() == _selectedCategory!.toLowerCase();
      }).toList();
    }

    switch (_sortBy) {
      case 'discount':
        filtered.sort((a, b) {
          final discountA = a.discountPrice != null
              ? (1 - (a.discountPrice! / a.originalPrice)) * 100
              : 0.0;
          final discountB = b.discountPrice != null
              ? (1 - (b.discountPrice! / b.originalPrice)) * 100
              : 0.0;
          return discountB.compareTo(discountA);
        });
        break;
      case 'price':
        filtered.sort((a, b) {
          final priceA = a.discountPrice ?? 0.0;
          final priceB = b.discountPrice ?? 0.0;
          return priceA.compareTo(priceB);
        });
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
    return GestureDetector(
      onTap: () => KeyboardUtils.dismissKeyboard(context),
      child: SafeArea(
        child: CustomScrollView(
          // Prevent layout jumps on keyboard open/close (esp. web)
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const ClampingScrollPhysics(),
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

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search offers, stores, categories...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.darkBlue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.darkBlue),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.darkBlue,
                        width: 1.1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.darkBlue,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
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
                  final categories = <String>{'All Categories'};
                  for (final offer in allOffers) {
                    if (offer.city != null && offer.city!.isNotEmpty) {
                      cities.add(offer.city!);
                    }
                    if (offer.businessCategory != null &&
                        offer.businessCategory!.isNotEmpty) {
                      categories.add(offer.businessCategory!);
                    }
                  }
                  final sortedCities = cities.toList()..sort();
                  final sortedCategories = categories.toList()..sort();

                  return SortFilterBar(
                    currentSortBy: _sortBy,
                    selectedCategory: _selectedCategory,
                    selectedCity: _selectedCity,
                    onSortChanged: (value) {
                      setState(() => _sortBy = value);
                    },
                    onCategoryChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    onCityChanged: (value) {
                      setState(() => _selectedCity = value);
                    },
                    availableCities: sortedCities,
                    availableCategories: sortedCategories,
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
                      child:
                          CircularProgressIndicator(color: AppColors.darkBlue),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final offer = filteredOffers[index];

                        // Calculate discount based on offer type
                        String discountText = '0% OFF';
                        if (offer.offerType == OfferType.percentageDiscount) {
                          final percentage = offer.percentageOff ?? 0;
                          discountText =
                              '${percentage.toStringAsFixed(0)}% OFF';
                        } else if (offer.offerType == OfferType.flatDiscount) {
                          final amount = offer.flatDiscountAmount ?? 0;
                          discountText = '₹${amount.toStringAsFixed(0)} OFF';
                        } else if (offer.offerType ==
                            OfferType.buyXGetYPercentOff) {
                          final percentage = offer.getPercentage ?? 0;
                          discountText =
                              '${percentage.toStringAsFixed(0)}% OFF';
                        } else if (offer.offerType ==
                            OfferType.buyXGetYRupeesOff) {
                          final amount = offer.flatDiscountAmount ?? 0;
                          discountText = '₹${amount.toStringAsFixed(0)} OFF';
                        } else if (offer.offerType == OfferType.bogo) {
                          discountText = 'BOGO';
                        } else if (offer.offerType ==
                            OfferType.productSpecific) {
                          discountText = 'DEAL';
                        } else if (offer.offerType ==
                            OfferType.serviceSpecific) {
                          discountText = 'DEAL';
                        } else if (offer.offerType == OfferType.bundleDeal) {
                          discountText = 'BUNDLE';
                        } else if (offer.discountPrice != null) {
                          // Fallback for any offer with discountPrice
                          discountText =
                              '${((1 - (offer.discountPrice! / offer.originalPrice)) * 100).toStringAsFixed(0)}% OFF';
                        }

                        final offerMap = <String, dynamic>{
                          'title': offer.title,
                          'store':
                              offer.client?['businessName'] ?? offer.clientId,
                          'image': offer.imageUrls?.isNotEmpty == true
                              ? offer.imageUrls![0]
                              : '',
                          'discount': discountText,
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
      ),
    );
  }
}
