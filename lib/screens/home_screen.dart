import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
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
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'All',
      'icon': Icons.grid_view_rounded,
      'color': const Color(0xFF1F477D),
      'gradient': [const Color(0xFF1F477D), const Color(0xFF2A5A9F)],
    },
    {
      'name': 'Grocery',
      'icon': Icons.shopping_cart_outlined,
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
    },
    {
      'name': 'Restaurant',
      'icon': Icons.restaurant_outlined,
      'color': const Color(0xFFFF9800),
      'gradient': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom_outlined,
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
    },
    {
      'name': 'Electronics',
      'icon': Icons.devices_outlined,
      'color': const Color(0xFF2196F3),
      'gradient': [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
    },
    {
      'name': 'Beauty',
      'icon': Icons.face_outlined,
      'color': const Color(0xFF9C27B0),
      'gradient': [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
    },
    {
      'name': 'Home & Garden',
      'icon': Icons.home_outlined,
      'color': const Color(0xFF795548),
      'gradient': [const Color(0xFF795548), const Color(0xFFA1887F)],
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_basketball_outlined,
      'color': const Color(0xFFFF5722),
      'gradient': [const Color(0xFFFF5722), const Color(0xFFFF8A65)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Premium AppBar

            // Premium Hero Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F477D), Color(0xFF2A5A9F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F477D).withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discover Amazing',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Deals & Offers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save big on your favorite products & services',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B84D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Browse by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Premium Category Cards Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'] ||
                        (_selectedCategory == null &&
                            category['name'] == 'All');

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['name'] == 'All'
                              ? null
                              : category['name'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: category['gradient'],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? category['color'].withAlpha(80)
                                  : Colors.black.withAlpha(8),
                              blurRadius: isSelected ? 12 : 8,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withAlpha(50)
                                    : category['color'].withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category['icon'],
                                color: isSelected
                                    ? Colors.white
                                    : category['color'],
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                category['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkBlue,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _categories.length,
                ),
              ),
            ),

            // Offers Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B84D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCategory == null
                            ? 'Latest Offers'
                            : '$_selectedCategory Offers',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Offers Grid
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
                            color: AppColors.darkBlue,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Oops! Something went wrong',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.darkBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please try again later',
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

                    final offers = snapshot.data ?? [];

                    // Filter by category
                    final filteredOffers = _selectedCategory == null
                        ? offers
                        : offers.where((offer) {
                            final client = offer.client;
                            final businessCategory = client != null &&
                                    client['businessCategory'] != null
                                ? client['businessCategory'].toString()
                                : null;
                            return businessCategory != null &&
                                businessCategory.toLowerCase() ==
                                    _selectedCategory!.toLowerCase();
                          }).toList();

                    if (filteredOffers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: AppColors.darkBlue.withAlpha(51),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedCategory == null
                                    ? 'No offers available yet'
                                    : 'No $_selectedCategory offers',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.darkBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredOffers.length,
                      itemBuilder: (context, i) {
                        final offer = filteredOffers[i];
                        final client = offer.client;
                        final businessName =
                            client != null && client['businessName'] != null
                                ? client['businessName'].toString()
                                : offer.clientId;
                        final imageUrls = offer.imageUrls;
                        final image = (imageUrls != null &&
                                imageUrls.isNotEmpty)
                            ? imageUrls[0]
                            : 'assets/images/logo/original/Logo_without_text_with_background.jpg';
                        final offerMap = <String, dynamic>{
                          'title': offer.title,
                          'store': businessName,
                          'image': image,
                          'discount':
                              '${((1 - (offer.discountPrice / offer.originalPrice)) * 100).toStringAsFixed(0)}% OFF',
                        };
                        return OfferCard(
                          offer: offerMap,
                          offerData: offer,
                          onTap: () {
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
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
