// ignore_for_file: prefer_const_declarations, curly_braces_in_flow_control_structures

import 'dart:async';
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
  final ScrollController _categoryScrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isAutoScrolling = true;

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
    {
      'name': 'Health',
      'icon': Icons.favorite_outline,
      'color': const Color(0xFFE53935),
      'gradient': [const Color(0xFFE53935), const Color(0xFFEF5350)],
    },
    {
      'name': 'Books',
      'icon': Icons.menu_book_outlined,
      'color': const Color(0xFF5E35B1),
      'gradient': [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
    },
    {
      'name': 'Toys',
      'icon': Icons.toys_outlined,
      'color': const Color(0xFFFDD835),
      'gradient': [const Color(0xFFFDD835), const Color(0xFFFFEE58)],
    },
    {
      'name': 'Automotive',
      'icon': Icons.directions_car_outlined,
      'color': const Color(0xFF616161),
      'gradient': [const Color(0xFF616161), const Color(0xFF757575)],
    },
    {
      'name': 'Pets',
      'icon': Icons.pets_outlined,
      'color': const Color(0xFF8D6E63),
      'gradient': [const Color(0xFF8D6E63), const Color(0xFFA1887F)],
    },
    {
      'name': 'Travel',
      'icon': Icons.flight_outlined,
      'color': const Color(0xFF00ACC1),
      'gradient': [const Color(0xFF00ACC1), const Color(0xFF26C6DA)],
    },
    {
      'name': 'Services',
      'icon': Icons.room_service_outlined,
      'color': const Color(0xFF43A047),
      'gradient': [const Color(0xFF43A047), const Color(0xFF66BB6A)],
    },
    {
      'name': 'Education',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF1E88E5),
      'gradient': [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isAutoScrolling ||
          !mounted ||
          !_categoryScrollController.hasClients) return;

      final maxScroll = _categoryScrollController.position.maxScrollExtent;
      final currentScroll = _categoryScrollController.offset;
      final scrollAmount = 200.0; // Scroll by 200 pixels

      if (currentScroll >= maxScroll - 10) {
        // Reset to start
        _categoryScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _categoryScrollController.animateTo(
          currentScroll + scrollAmount,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onCategoryScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _isAutoScrolling = false;
    } else if (notification is ScrollEndNotification) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _isAutoScrolling = true;
        }
      });
    }
  }

  Map<String, int> _getCategoryCounts(List<Offer> offers) {
    final counts = <String, int>{};
    for (final category in _categories) {
      final name = category['name'] as String;
      if (name == 'All') {
        counts[name] = offers.length;
      } else {
        counts[name] = offers.where((offer) {
          // Match category name with offer title/description/client business name
          final searchText =
              '${offer.title} ${offer.description} ${offer.client?['businessName'] ?? ''}'
                  .toLowerCase();
          return searchText.contains(name.toLowerCase());
        }).length;
      }
    }
    return counts;
  }

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

            // Premium Category Cards - Horizontal Scrollable
            SliverToBoxAdapter(
              child: Consumer<OfferService>(
                builder: (context, offerService, _) {
                  return StreamBuilder<List<Offer>>(
                    stream: offerService.watchApprovedOffers(),
                    builder: (context, snapshot) {
                      final offers = snapshot.data ?? [];
                      final counts = _getCategoryCounts(offers);

                      return SizedBox(
                        height: 110,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            _onCategoryScroll(notification);
                            return false;
                          },
                          child: ListView.builder(
                            controller: _categoryScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected =
                                  _selectedCategory == category['name'] ||
                                      (_selectedCategory == null &&
                                          category['name'] == 'All');
                              final offerCount = counts[category['name']] ?? 0;

                              // Custom style for 'All' card: white background, split blue/orange icon
                              final isAll = category['name'] == 'All';
                              final cardDecoration = isSelected
                                  ? BoxDecoration(
                                      color:
                                          const Color(0xFFF9E5B2), // light gold
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    )
                                  : isAll
                                      ? BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.06),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        )
                                      : BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        );
                              final iconColor = isSelected
                                  ? AppColors.darkBlue
                                  : (isAll ? Colors.white : category['color']);
                              final textColor = isSelected
                                  ? AppColors.darkBlue
                                  : (isAll ? Colors.black : AppColors.darkBlue);

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory =
                                          category['name'] == 'All'
                                              ? null
                                              : category['name'];
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 72,
                                    height: 92,
                                    decoration: cardDecoration,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: isSelected && isAll
                                                      ? Colors.white
                                                          .withOpacity(0.12)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: isAll
                                                    ? ShaderMask(
                                                        shaderCallback: (bounds) =>
                                                            const LinearGradient(
                                                          colors: [
                                                            AppColors.darkBlue,
                                                            AppColors.darkBlue,
                                                            AppColors
                                                                .brightGold,
                                                            AppColors
                                                                .brightGold,
                                                          ],
                                                          stops: [
                                                            0,
                                                            0.5,
                                                            0.5,
                                                            1
                                                          ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        ).createShader(bounds),
                                                        blendMode:
                                                            BlendMode.srcIn,
                                                        child: Icon(
                                                          category['icon'],
                                                          color: iconColor,
                                                          size: 22,
                                                        ),
                                                      )
                                                    : Icon(
                                                        category['icon'],
                                                        color: iconColor,
                                                        size: 22,
                                                      ),
                                              ),
                                              const SizedBox(height: 7),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2),
                                                child: Text(
                                                  category['name'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: textColor,
                                                    letterSpacing: 0.1,
                                                    height: 1.13,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (offerCount > 0)
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isAll
                                                        ? AppColors.brightGold
                                                        : AppColors.brightGold),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha((0.15 * 255)
                                                            .toInt()),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                offerCount > 99
                                                    ? '99+'
                                                    : offerCount.toString(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: isSelected
                                                      ? (isAll
                                                          ? AppColors.darkBlue
                                                          : category['color'])
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
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
                        childAspectRatio: 0.55,
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
                        final image =
                            (imageUrls != null && imageUrls.isNotEmpty)
                                ? imageUrls[0]
                                : '';
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
