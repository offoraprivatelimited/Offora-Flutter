import 'package:flutter/material.dart';
import '../screens/about_us_page.dart';
import '../screens/contact_us_page.dart';
import '../screens/terms_and_conditions_page.dart';
import '../screens/privacy_policy_page.dart';
import '../screens/main_screen.dart';
import '../client/screens/main/client_main_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to find MainScreen or ClientMainScreen state to show pages inline
    final mainScreenState =
        context.findAncestorStateOfType<State<MainScreen>>();
    final clientMainScreenState =
        context.findAncestorStateOfType<State<ClientMainScreen>>();

    void navigateToPage(Widget page) {
      if (mainScreenState != null) {
        // If we're in MainScreen, show page inline
        (mainScreenState as dynamic).showInfoPage(page);
      } else if (clientMainScreenState != null) {
        // If we're in ClientMainScreen, show page inline
        (clientMainScreenState as dynamic).showInfoPage(page);
      } else {
        // Fallback to regular navigation
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1F477D),
                elevation: 1,
              ),
              body: page,
            ),
          ),
        );
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1F477D),
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 32, color: Color(0xFF1F477D)),
                  ),
                ),
                const Positioned(
                  left: 0,
                  bottom: 8,
                  child: Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            onTap: () => navigateToPage(const AboutUsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail_outlined),
            title: const Text('Contact Us'),
            onTap: () => navigateToPage(const ContactUsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => navigateToPage(const PrivacyPolicyPage()),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            onTap: () => navigateToPage(const TermsAndConditionsPage()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              // Implement sign out logic
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
