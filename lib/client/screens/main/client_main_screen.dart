import 'package:flutter/material.dart';
// import '../dashboard/dashboard_screen.dart';
import '../dashboard/manage_offers_screen.dart';
import '../dashboard/enquiries_screen.dart';
import '../dashboard/client_profile_screen.dart';
import '../offers/new_offer_form_screen.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/premium_app_bar.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  static const String routeName = '/client-main';

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  // Keep index in sync with BottomNavigationBar items (0..4)
  int _currentIndex = 1; // default to Manage
  Widget? _infoPage;

  final List<Widget> _screens = const [
    NewOfferFormScreen(),
    ManageOffersScreen(),
    EnquiriesScreen(),
    ClientProfileScreen(),
  ];

  void showInfoPage(Widget page) {
    setState(() {
      _infoPage = page;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  void clearInfoPage() {
    setState(() {
      _infoPage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const brightGold = Color(0xFFF0B84D);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Builder(
          builder: (context) => PremiumAppBar(
            showBack: _infoPage != null,
            onBackTap: () => setState(() => _infoPage = null),
            showMenu: _infoPage == null,
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _infoPage != null
          ? _infoPage!
          : Container(
              color: const Color(0xFFF5F7FA),
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _infoPage = null; // Clear info page when switching tabs
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: brightGold,
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          showUnselectedLabels: true,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Manage',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer_outlined),
              activeIcon: Icon(Icons.question_answer),
              label: 'Enquiries',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
