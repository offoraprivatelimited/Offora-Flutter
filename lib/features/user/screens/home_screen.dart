// ignore_for_file: prefer_const_declarations, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:flutter/material.dart';
import 'advertisement_details_screen.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/colors.dart';
import '../../client/models/offer.dart';
import '../../client/services/offer_service.dart';
import '../../../shared/widgets/offer_card.dart';
import '../../../core/utils/keyboard_utils.dart';
import 'main_screen.dart';
import '../services/offer_banner_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  late PageController _bannerPageController;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(viewportFraction: 0.93);
    _startAutoBannerScroll();
    _startAutoScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize PageController with correct viewport fraction after dependencies are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final screenWidth = MediaQuery.of(context).size.width;
      final newViewportFraction = screenWidth < 768 ? 1.0 : 0.93;
      if (_bannerPageController.viewportFraction != newViewportFraction) {
        _bannerPageController.dispose();
        _bannerPageController =
            PageController(viewportFraction: newViewportFraction);
      }
    });
  }

  void _startAutoBannerScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_bannerPageController.hasClients) return;
      final next = _bannerIndex + 1;
      _bannerPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _autoScrollTimer?.cancel();
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? _selectedCategory;
  final ScrollController _categoryScrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isAutoScrolling = true;
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';

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
      'name': 'Supermarket',
      'icon': Icons.storefront_outlined,
      'color': const Color(0xFF388E3C),
      'gradient': [const Color(0xFF388E3C), const Color(0xFF66BB6A)],
    },
    {
      'name': 'Restaurant',
      'icon': Icons.restaurant_outlined,
      'color': const Color(0xFFFF9800),
      'gradient': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
    },
    {
      'name': 'Cafe & Bakery',
      'icon': Icons.coffee_outlined,
      'color': const Color(0xFF795548),
      'gradient': [const Color(0xFF795548), const Color(0xFFD7CCC8)],
    },
    {
      'name': 'Pharmacy',
      'icon': Icons.local_pharmacy_outlined,
      'color': const Color(0xFF009688),
      'gradient': [const Color(0xFF009688), const Color(0xFF4DB6AC)],
    },
    {
      'name': 'Electronics',
      'icon': Icons.devices_outlined,
      'color': const Color(0xFF2196F3),
      'gradient': [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
    },
    {
      'name': 'Mobile & Accessories',
      'icon': Icons.smartphone_outlined,
      'color': const Color(0xFF1976D2),
      'gradient': [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
    },
    {
      'name': 'Fashion & Apparel',
      'icon': Icons.checkroom_outlined,
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
    },
    {
      'name': 'Footwear',
      'icon': Icons.hiking_outlined,
      'color': const Color(0xFF6D4C41),
      'gradient': [const Color(0xFF6D4C41), const Color(0xFFA1887F)],
    },
    {
      'name': 'Jewelry',
      'icon': Icons.diamond_outlined,
      'color': const Color(0xFFFFD700),
      'gradient': [const Color(0xFFFFD700), const Color(0xFFFFF9C4)],
    },
    {
      'name': 'Home Decor',
      'icon': Icons.chair_outlined,
      'color': const Color(0xFF795548),
      'gradient': [const Color(0xFF795548), const Color(0xFFA1887F)],
    },
    {
      'name': 'Furniture',
      'icon': Icons.weekend_outlined,
      'color': const Color(0xFF8D6E63),
      'gradient': [const Color(0xFF8D6E63), const Color(0xFFD7CCC8)],
    },
    {
      'name': 'Hardware',
      'icon': Icons.handyman_outlined,
      'color': const Color(0xFF607D8B),
      'gradient': [const Color(0xFF607D8B), const Color(0xFF90A4AE)],
    },
    {
      'name': 'Automotive',
      'icon': Icons.directions_car_outlined,
      'color': const Color(0xFF616161),
      'gradient': [const Color(0xFF616161), const Color(0xFF757575)],
    },
    {
      'name': 'Books & Stationery',
      'icon': Icons.menu_book_outlined,
      'color': const Color(0xFF5E35B1),
      'gradient': [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
    },
    {
      'name': 'Toys & Games',
      'icon': Icons.toys_outlined,
      'color': const Color(0xFFFDD835),
      'gradient': [const Color(0xFFFDD835), const Color(0xFFFFEE58)],
    },
    {
      'name': 'Sports & Fitness',
      'icon': Icons.sports_basketball_outlined,
      'color': const Color(0xFFFF5722),
      'gradient': [const Color(0xFFFF5722), const Color(0xFFFF8A65)],
    },
    {
      'name': 'Beauty & Cosmetics',
      'icon': Icons.face_outlined,
      'color': const Color(0xFF9C27B0),
      'gradient': [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
    },
    {
      'name': 'Salon & Spa',
      'icon': Icons.spa_outlined,
      'color': const Color(0xFF8E24AA),
      'gradient': [const Color(0xFF8E24AA), const Color(0xFFCE93D8)],
    },
    {
      'name': 'Pet Supplies',
      'icon': Icons.pets_outlined,
      'color': const Color(0xFF8D6E63),
      'gradient': [const Color(0xFF8D6E63), const Color(0xFFA1887F)],
    },
    {
      'name': 'Dairy & Produce',
      'icon': Icons.egg_outlined,
      'color': const Color(0xFFFFF176),
      'gradient': [const Color(0xFFFFF176), const Color(0xFFFFF9C4)],
    },
    {
      'name': 'Electronics Repair',
      'icon': Icons.build_outlined,
      'color': const Color(0xFF607D8B),
      'gradient': [const Color(0xFF607D8B), const Color(0xFF90A4AE)],
    },
    {
      'name': 'Optical',
      'icon': Icons.remove_red_eye_outlined,
      'color': const Color(0xFF00ACC1),
      'gradient': [const Color(0xFF00ACC1), const Color(0xFF26C6DA)],
    },
    {
      'name': 'Travel & Tours',
      'icon': Icons.flight_outlined,
      'color': const Color(0xFF00ACC1),
      'gradient': [const Color(0xFF00ACC1), const Color(0xFF26C6DA)],
    },
    {
      'name': 'Department Store',
      'icon': Icons.apartment_outlined,
      'color': const Color(0xFF1F477D),
      'gradient': [const Color(0xFF1F477D), const Color(0xFF2A5A9F)],
    },
    {
      'name': 'Construction',
      'icon': Icons.home_repair_service_outlined,
      'color': const Color(0xFFFF8A65),
      'gradient': [const Color(0xFFFF8A65), const Color(0xFFFFAB91)],
    },
    {
      'name': 'Other',
      'icon': Icons.category_outlined,
      'color': const Color(0xFFBDBDBD),
      'gradient': [const Color(0xFFBDBDBD), const Color(0xFFE0E0E0)],
    },
  ];

  // Removed duplicate initState()

  // Removed duplicate dispose() method. All dispose logic is now in a single method above.

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
    return GestureDetector(
      onTap: () => KeyboardUtils.dismissKeyboard(context),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use the same layout for all screen sizes
              return _buildMobileContent(constraints);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(BoxConstraints constraints) {
    final crossAxisCount = constraints.maxWidth > 750 ? 3 : 2;
    final isDesktop = constraints.maxWidth > 1200;
    final sectionPadding = isDesktop ? 0.0 : 16.0;
    final categoryPadding = isDesktop ? 0.0 : 16.0;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Premium Hero Section
        SliverToBoxAdapter(
          child: StreamBuilder<List<OfferBanner>>(
            stream: OfferBannerService().watchOfferBanners(),
            builder: (context, snapshot) {
              final banners = snapshot.data ?? [];
              if (banners.isEmpty) {
                return const SizedBox(height: 0);
              }

              // Responsive banner height based on screen size
              final screenWidth = MediaQuery.of(context).size.width;
              final isMobile = screenWidth < 768;
              final bannerHeight = screenWidth > 1200
                  ? 450.0
                  : screenWidth > 768
                      ? 320.0
                      : 180.0;
              final horizontalMargin =
                  isDesktop ? 0.0 : (isMobile ? 0.0 : 16.0);
              final itemHorizontalMargin =
                  isDesktop ? 0.0 : (isMobile ? 0.0 : 8.0);

              return Column(
                children: [
                  Container(
                    height: bannerHeight,
                    margin: EdgeInsets.symmetric(
                        horizontal: horizontalMargin, vertical: 16),
                    child: PageView.builder(
                      controller: _bannerPageController,
                      itemCount: banners.length,
                      onPageChanged: (i) {
                        setState(() => _bannerIndex = i);
                      },
                      itemBuilder: (context, i) {
                        final banner = banners[i];
                        return GestureDetector(
                          onTap: () {
                            final mainScreenState = context
                                .findAncestorStateOfType<MainScreenState>();
                            if (mainScreenState != null) {
                              mainScreenState.showInfoPage(
                                AdvertisementDetailsScreen(
                                  title: banner.title ?? '',
                                  description: banner.description ?? '',
                                  email: banner.email ?? '',
                                  phone: banner.phone ?? '',
                                  link: banner.link ?? '',
                                  imageUrl: banner.url,
                                ),
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            margin: EdgeInsets.symmetric(
                                horizontal: itemHorizontalMargin, vertical: 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: banner.url.isNotEmpty
                                ? Stack(
                                    children: [
                                      Image.network(
                                        banner.url,
                                        fit: BoxFit.fitWidth,
                                        width: double.infinity,
                                        height: double.infinity,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: progress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? progress
                                                          .cumulativeBytesLoaded /
                                                      (progress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                      // Gradient overlay for better text readability
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.black
                                                  .withValues(alpha: 0.0),
                                              Colors.black
                                                  .withValues(alpha: 0.2),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(banners.length, (i) {
                      final isActive = i == _bannerIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1F477D)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),

        // Categories Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(sectionPadding, 4, sectionPadding, 8),
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
                    height: 90,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        _onCategoryScroll(notification);
                        return false;
                      },
                      child: ListView.builder(
                        controller: _categoryScrollController,
                        scrollDirection: Axis.horizontal,
                        padding:
                            EdgeInsets.symmetric(horizontal: categoryPadding),
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
                                  color: const Color(0xFFF9E5B2), // light gold
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                )
                              : isAll
                                  ? BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    )
                                  : BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
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
                                  _selectedCategory = category['name'] == 'All'
                                      ? null
                                      : category['name'];
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 72,
                                height: 75,
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
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isSelected && isAll
                                                  ? Colors.white
                                                      .withValues(alpha: 0.12)
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
                                                        AppColors.brightGold,
                                                        AppColors.brightGold,
                                                      ],
                                                      stops: [0, 0.5, 0.5, 1],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    ).createShader(bounds),
                                                    blendMode: BlendMode.srcIn,
                                                    child: Icon(
                                                      category['icon'],
                                                      color: iconColor,
                                                      size: 20,
                                                    ),
                                                  )
                                                : Icon(
                                                    category['icon'],
                                                    color: iconColor,
                                                    size: 20,
                                                  ),
                                          ),
                                          const SizedBox(height: 3),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                              overflow: TextOverflow.ellipsis,
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
                                          padding: const EdgeInsets.symmetric(
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
                                                color: Colors.black.withAlpha(
                                                    (0.15 * 255).toInt()),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
          padding: EdgeInsets.symmetric(horizontal: sectionPadding),
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

                // Filter by category and search query
                final filteredOffers = offers.where((offer) {
                  // Category filter
                  if (_selectedCategory != null) {
                    // Check offer's own businessCategory first
                    String? businessCategory = offer.businessCategory;

                    // Fallback to client's businessCategory if offer doesn't have one
                    if (businessCategory == null || businessCategory.isEmpty) {
                      final client = offer.client;
                      businessCategory =
                          client != null && client['businessCategory'] != null
                              ? client['businessCategory'].toString()
                              : null;
                    }

                    if (businessCategory == null ||
                        businessCategory.toLowerCase() !=
                            _selectedCategory!.toLowerCase()) {
                      return false;
                    }
                  }

                  // Search query filter
                  if (_searchQuery.isNotEmpty) {
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

                    final searchableText =
                        searchableFields.join(' ').toLowerCase();

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
                  }

                  return true;
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 252.0,
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
                    final image = (imageUrls != null && imageUrls.isNotEmpty)
                        ? imageUrls[0]
                        : '';

                    // Calculate discount based on offer type
                    String discountText = '0% OFF';
                    if (offer.offerType == OfferType.percentageDiscount) {
                      final percentage = offer.percentageOff ?? 0;
                      discountText = '${percentage.toStringAsFixed(0)}% OFF';
                    } else if (offer.offerType == OfferType.flatDiscount) {
                      final amount = offer.flatDiscountAmount ?? 0;
                      discountText = '₹${amount.toStringAsFixed(0)} OFF';
                    } else if (offer.offerType ==
                        OfferType.buyXGetYPercentOff) {
                      final percentage = offer.getPercentage ?? 0;
                      discountText = '${percentage.toStringAsFixed(0)}% OFF';
                    } else if (offer.offerType == OfferType.buyXGetYRupeesOff) {
                      final amount = offer.flatDiscountAmount ?? 0;
                      discountText = '₹${amount.toStringAsFixed(0)} OFF';
                    } else if (offer.offerType == OfferType.bogo) {
                      discountText = 'BOGO';
                    } else if (offer.offerType == OfferType.productSpecific) {
                      discountText = 'DEAL';
                    } else if (offer.offerType == OfferType.serviceSpecific) {
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
                      'store': businessName,
                      'image': image,
                      'discount': discountText,
                    };
                    return OfferCard(
                      offer: offerMap,
                      offerData: offer,
                      onTap: () {
                        final mainScreenState =
                            context.findAncestorStateOfType<MainScreenState>();
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
    );
  }
}
