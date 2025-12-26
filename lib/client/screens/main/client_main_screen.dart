import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import '../dashboard/dashboard_screen.dart';
import '../dashboard/manage_offers_screen.dart';
import '../dashboard/enquiries_screen.dart';
import '../dashboard/client_profile_screen.dart';
import '../offers/new_offer_form_screen.dart';
import '../../models/offer.dart';
import '../../services/offer_service.dart';
import '../../../services/auth_service.dart';
import '../../../core/error_messages.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/premium_app_bar.dart';
import '../../../widgets/app_exit_dialog.dart';

class ClientMainScreen extends StatefulWidget {
  static const String routeName = '/client-main';

  final int initialIndex;

  const ClientMainScreen({
    super.key,
    this.initialIndex = 1,
  });

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  // Keep index in sync with BottomNavigationBar items (0..4)
  late int _currentIndex;
  Widget? _infoPage;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final clientId = context.read<AuthService>().currentUser?.uid ?? '';
    _screens.addAll([
      NewOfferFormScreen(clientId: clientId),
      ManageOffersScreen(
        onEditOffer: _editOffer,
        onDeleteOffer: _deleteOffer,
      ),
      const EnquiriesScreen(),
      const ClientProfileScreen(),
    ]);
  }

  String get _clientId {
    final auth = Provider.of<AuthService>(context, listen: false);
    return auth.currentUser?.uid ?? '';
  }

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

  Future<void> _editOffer(Offer offer) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final clientId = auth.currentUser?.uid ?? '';

    setState(() {
      _infoPage = NewOfferFormScreen(
        clientId: clientId,
        offerToEdit: offer,
      );
    });
  }

  Future<void> _deleteOffer(Offer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text('Are you sure you want to delete "${offer.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        final service = context.read<OfferService>();
        await service.deleteOffer(offer.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer deleted successfully.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.friendlyErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brightGold = Color(0xFFF0B84D);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Show exit dialog when user tries to go back (browser back, swipe back, etc.)
        if (didPop) return;
        await AppExitDialog.show(
          context,
          userRole: 'shopowner',
          isExiting: true,
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // Keep drawer for narrow screens
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
        body: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 920;

          // Update the first screen with actual NewOfferFormScreen
          if (_screens.isNotEmpty && _screens[0] is SizedBox) {
            _screens[0] = NewOfferFormScreen(clientId: _clientId);
          }

          Widget content = _infoPage != null
              ? _infoPage!
              : Container(
                  color: const Color(0xFFF5F7FA),
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                );

          if (!isWide) return content;

          // Desktop layout: navigation rail + content
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) {
                  setState(() {
                    _currentIndex = i;
                    _infoPage = null;
                  });
                  // Update URL based on tab selection
                  switch (i) {
                    case 0:
                      context.goNamed('client-add');
                      break;
                    case 1:
                      context.goNamed('client-manage');
                      break;
                    case 2:
                      context.goNamed('client-enquiries');
                      break;
                    case 3:
                      context.goNamed('client-profile');
                      break;
                  }
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.add_circle_outline),
                    selectedIcon: Icon(Icons.add_circle),
                    label: Text('Add'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.campaign_outlined),
                    selectedIcon: Icon(Icons.campaign),
                    label: Text('Manage'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.question_answer_outlined),
                    selectedIcon: Icon(Icons.question_answer),
                    label: Text('Enquiries'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: content,
                  ),
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 920) return const SizedBox.shrink();
          return Container(
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
                // Update URL based on tab selection
                switch (index) {
                  case 0:
                    context.goNamed('client-add');
                    break;
                  case 1:
                    context.goNamed('client-manage');
                    break;
                  case 2:
                    context.goNamed('client-enquiries');
                    break;
                  case 3:
                    context.goNamed('client-profile');
                    break;
                }
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
          );
        }),
      ),
    );
  }
}
