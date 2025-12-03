import 'package:flutter/material.dart';
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
      body: _infoPage != null
          ? Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 1,
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF1F477D)),
                    onPressed: clearInfoPage,
                  ),
                  title: SizedBox(
                    height: 28,
                    child: Image.asset(
                      'assets/images/logo/original/Text_without_logo_without_background.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(child: _infoPage!),
              ],
            )
          : _selectedOffer != null
              ? Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF1F477D)),
                        onPressed: clearInfoPage,
                      ),
                      title: SizedBox(
                        height: 28,
                        child: Image.asset(
                          'assets/images/logo/original/Text_without_logo_without_background.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: OfferDetailsContent(offer: _selectedOffer!),
                    ),
                  ],
                )
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
