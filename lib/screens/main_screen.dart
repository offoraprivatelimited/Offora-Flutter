import 'package:flutter/material.dart';
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

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _index = 0;
  Widget? _infoPage;
  Offer? _selectedOffer;

  final List<Widget> _tabs = const [
    HomeScreen(),
    ExploreScreen(),
    CompareScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

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
      drawer: const AppDrawer(),
      body: Column(
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
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() {
          _index = i;
          _infoPage = null; // Clear info page when switching tabs
          _selectedOffer = null;
        }),
      ),
    );
  }
}
