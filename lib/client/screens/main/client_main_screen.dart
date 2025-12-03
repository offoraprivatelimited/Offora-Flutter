import 'package:flutter/material.dart';
// import '../dashboard/dashboard_screen.dart';
import '../dashboard/manage_offers_screen.dart';
import '../dashboard/enquiries_screen.dart';
import '../dashboard/client_profile_screen.dart';
import '../offers/new_offer_form_screen.dart';
import 'add_offer_entry_screen.dart';
import '../../../widgets/app_drawer.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  static const String routeName = '/client-main';

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  // Keep index in sync with BottomNavigationBar items (0..3)
  int _currentIndex = 1; // default to Manage
  Widget? _infoPage;

  final List<Widget> _screens = const [
    AddOfferEntryScreen(),
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
    final titles = ['', 'Manage Offers', 'Enquiries', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 44,
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (ctx) => Row(
            children: [
              IconButton(
                icon: _infoPage != null
                    ? const Icon(Icons.arrow_back, color: Color(0xFF1F477D))
                    : const Icon(Icons.menu, color: Color(0xFF1F477D)),
                onPressed: () {
                  if (_infoPage != null) {
                    clearInfoPage();
                  } else {
                    Scaffold.of(ctx).openDrawer();
                  }
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                child: Image.asset(
                  'assets/images/logo/original/Text_without_logo_without_background.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F477D)),
      ),
      drawer: const AppDrawer(),
      body: _infoPage != null
          ? _infoPage!
          : Column(
              children: [
                // Title row placed below the stable AppBar
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    titles[_currentIndex],
                    style: const TextStyle(
                      color: Color(0xFF1F477D),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
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
          onTap: (index) async {
            if (index == 0) {
              // Treat the first tab as a quick action to add an offer.
              await Navigator.of(context)
                  .pushNamed(NewOfferFormScreen.routeName);
              return;
            }
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
