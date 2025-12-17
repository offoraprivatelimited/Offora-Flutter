import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:offora/widgets/premium_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'compare_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'offer_details_screen.dart';

import '../client/models/offer.dart';
import '../widgets/offer_scroller.dart';
import '../services/offer_scroller_service.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  // Global key so other routes/widgets can ask MainScreen to show inline pages
  static final GlobalKey<MainScreenState> globalKey =
      GlobalKey<MainScreenState>();

  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _index;
  Widget? _infoPage;
  Offer? _selectedOffer;

  final List<Widget> _tabs = const [
    HomeScreen(),
    ExploreScreen(),
    CompareScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void showInfoPage(Widget page) {
    setState(() {
      _infoPage = page;
      _selectedOffer = null;
    });
    // Removed pop to avoid closing the current page when showing info inline
  }

  void showOfferDetails(Offer offer) {
    setState(() {
      _selectedOffer = offer;
      _infoPage = null;
    });
  }

  void clearInfoPage() {
    setState(() {
      _infoPage = null;
      _selectedOffer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: const PremiumAppBar(),
      // Keep drawer for narrow screens
      drawer: const AppDrawer(),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 920;

        Widget mainContent = Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // OfferScroller always below AppBar
            StreamBuilder<List<String>>(
              stream: OfferScrollerService().watchOfferScrollerTexts(),
              builder: (context, snapshot) {
                final texts =
                    snapshot.data ?? ['Welcome to Offora - The offer world'];
                return OfferScroller(texts: texts);
              },
            ),
            Expanded(
              child: _infoPage != null
                  ? _infoPage!
                  : _selectedOffer != null
                      ? OfferDetailsContent(offer: _selectedOffer!)
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: _tabs[_index],
                        ),
            ),
          ],
        );

        if (!isWide) {
          return mainContent;
        }

        // Desktop layout: NavigationRail on the left + content on the right
        return Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) {
                setState(() {
                  _index = i;
                  _infoPage = null;
                  _selectedOffer = null;
                });
                // Update URL based on tab selection
                switch (i) {
                  case 0:
                    context.goNamed('home');
                    break;
                  case 1:
                    context.goNamed('explore');
                    break;
                  case 2:
                    context.goNamed('compare');
                    break;
                  case 3:
                    context.goNamed('saved');
                    break;
                  case 4:
                    context.goNamed('profile');
                    break;
                }
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: Text('Explore'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.compare_arrows_outlined),
                  selectedIcon: Icon(Icons.compare_arrows),
                  label: Text('Compare'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('Saved'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            // Constrain the app content width for comfortable reading
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: mainContent,
                ),
              ),
            ),
          ],
        );
      }),
      // Keep bottom nav only for narrow screens — handled by MainScreen caller
      bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 920) return const SizedBox.shrink();
        return CustomBottomNavBar(
          currentIndex: _index,
          onTap: (i) {
            setState(() {
              _index = i;
              _infoPage = null; // Clear info page when switching tabs
              _selectedOffer = null;
            });
            // Update URL based on tab selection
            switch (i) {
              case 0:
                context.goNamed('home');
                break;
              case 1:
                context.goNamed('explore');
                break;
              case 2:
                context.goNamed('compare');
                break;
              case 3:
                context.goNamed('saved');
                break;
              case 4:
                context.goNamed('profile');
                break;
            }
          },
        );
      }),
    );
  }
}
