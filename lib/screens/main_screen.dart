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

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
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
    Navigator.of(context).pop(); // Close drawer
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
      extendBody: true,
      appBar: const PremiumAppBar(),
      drawer: const AppDrawer(),
      body: _infoPage != null
          ? _infoPage!
          : _selectedOffer != null
              ? OfferDetailsContent(offer: _selectedOffer!)
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _tabs[_index],
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
