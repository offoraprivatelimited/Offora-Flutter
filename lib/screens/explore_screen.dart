import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../widgets/offer_card.dart';
import '../widgets/empty_state.dart';
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
  String? _selectedCategory;
  String _sortBy = 'newest'; // newest, discount, price
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Grocery',
    'Restaurant',
    'Fashion',
    'Electronics',
    'Beauty',
    'Home & Garden',
    'Sports',
    'Books',
    'Other',
  ];

  List<Offer> _filterOffers(List<Offer> offers) {
    var filtered = offers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((offer) {
        return offer.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            offer.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (offer.client?['businessName'] ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedCategory != null && _selectedCategory != 'All') {
      filtered = filtered.where((offer) {
        final businessCategory = offer.client?['businessCategory'] as String?;
        return businessCategory?.toLowerCase() ==
            _selectedCategory!.toLowerCase();
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _SortOption(
                    title: 'Newest First',
                    value: 'newest',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      Navigator.pop(context);
                    },
                  ),
                  _SortOption(
                    title: 'Highest Discount',
                    value: 'discount',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      Navigator.pop(context);
                    },
                  ),
                  _SortOption(
                    title: 'Lowest Price',
                    value: 'price',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showSortOptions,
                    icon: const Icon(Icons.sort, size: 18),
                    label: Text(_getSortLabel()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBlue,
                      side: const BorderSide(color: AppColors.darkBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                cursorColor: AppColors.darkBlue,
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search offers...',
                  hintStyle: TextStyle(
                    color: AppColors.darkBlue.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.darkBlue),
                  suffixIcon: _searchQuery.isNotEmpty
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.darkBlue,
                      width: 1.2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.darkBlue.withOpacity(0.35),
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
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category ||
                      (_selectedCategory == null && category == 'All');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory =
                              category == 'All' ? null : category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
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

              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Oops!',
                    message: 'Something went wrong. Please try again.',
                  ),
                );
              }

              final allOffers = snapshot.data ?? [];
              final filteredOffers = _filterOffers(allOffers);

              if (filteredOffers.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: 'No offers found',
                    message: _searchQuery.isNotEmpty
                        ? 'Try adjusting your search or filters'
                        : 'Check back soon for new deals!',
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

  String _getSortLabel() {
    switch (_sortBy) {
      case 'discount':
        return 'Highest Discount';
      case 'price':
        return 'Lowest Price';
      case 'newest':
      default:
        return 'Newest First';
    }
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final void Function(String?) onChanged;

  const _SortOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Newer Flutter versions deprecate `groupValue`/`onChanged` on RadioListTile
    // in favor of a RadioGroup ancestor. Rather than introduce a new ancestor
    // type here we render a simple selectable ListTile that avoids the
    // deprecated members and keeps behavior identical for our small local use.
    final selected = value == groupValue;

    return ListTile(
      onTap: () => onChanged(value),
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.darkBlue : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.darkBlue : Colors.grey.shade400,
            width: 1.4,
          ),
        ),
        child: selected
            ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
            : null,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
