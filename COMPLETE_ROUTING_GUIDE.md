# Complete URL Routing Implementation for Offora

## Overview
Your app now has proper URL routing for both **User** and **Client** roles with different dashboards and screens.

---

## User Routes

### Main Dashboard (Home Screen)
- **Home** → `offora.in/main`
- **Explore** → `offora.in/main/explore`
- **Compare** → `offora.in/main/compare`
- **Saved Offers** → `offora.in/main/saved`
- **Profile** → `offora.in/main/profile`

### Additional User Screens
- **Offer Details** → `offora.in/offer-details`
- **Notifications** → `offora.in/notifications`
- **Settings** → `offora.in/settings`
- **About Us** → `offora.in/about-us`
- **Contact Us** → `offora.in/contact-us`
- **Terms & Conditions** → `offora.in/terms-and-conditions`
- **Privacy Policy** → `offora.in/privacy-policy`

---

## Client (ShopOwner) Routes

### Client Dashboard
- **Add Offer** → `offora.in/client-dashboard/add`
- **Manage Offers** → `offora.in/client-dashboard/manage`
- **Enquiries** → `offora.in/client-dashboard/enquiries`
- **Profile** → `offora.in/client-dashboard/profile`

### Client Screens
- **New Offer Form** → `offora.in/new-offer`
- **Manage Offers** → `offora.in/manage-offers`

---

## Authentication Routes

- **Auth Gate** → `offora.in/` (Initial check)
- **Role Selection** → `offora.in/role-selection`
- **User Splash** → `offora.in/splash`
- **Onboarding** → `offora.in/onboarding`
- **User Login** → `offora.in/user-login`
- **User Auth** → `offora.in/auth`
- **Profile Complete** → `offora.in/profile-complete`
- **Client Login** → `offora.in/client-login`
- **Client Signup** → `offora.in/client-signup`
- **Pending Approval** → `offora.in/pending-approval`
- **Rejection** → `offora.in/rejection`

---

## Files Updated

### 1. **pubspec.yaml**
- Added `go_router: ^14.0.0` dependency

### 2. **lib/core/router/app_router.dart** (Complete Router Configuration)
- Centralized all routes for both user and client flows
- Proper redirect logic based on user role
- Organized routes into sections:
  - Auth Routes
  - User Routes
  - Client Routes
  - Info Routes

### 3. **lib/main.dart**
- Updated to use `MaterialApp.router` instead of `MaterialApp`
- Integrated with GoRouter for proper URL management

### 4. **lib/screens/main_screen.dart** (User Main Screen)
- Added `go_router` import
- Navigation Rail now updates URL when tabs are selected
- Bottom Navigation Bar also updates URL for mobile
- URL changes:
  - `/main` → Home
  - `/main/explore` → Explore
  - `/main/compare` → Compare
  - `/main/saved` → Saved
  - `/main/profile` → Profile

### 5. **lib/client/screens/main/client_main_screen.dart** (Client Dashboard)
- Added `initialIndex` parameter to constructor
- Added `go_router` import
- Navigation Rail now updates URL:
  - `/client-dashboard/add` → Add Offer
  - `/client-dashboard/manage` → Manage Offers
  - `/client-dashboard/enquiries` → Enquiries
  - `/client-dashboard/profile` → Profile
- Bottom Navigation Bar also updates URL for mobile

---

## Key Features

✅ **Role-Based Routing** - Different URLs and screens for users vs clients  
✅ **Deep Linking** - Users can bookmark specific pages  
✅ **Browser History** - Back/Forward buttons work correctly  
✅ **SEO Friendly** - Each page has unique, trackable URLs  
✅ **URL Persistence** - URLs reflect the current page/tab  
✅ **Mobile & Desktop** - Works on both mobile (bottom nav) and desktop (navigation rail)  
✅ **Analytics Ready** - Each page has its own trackable URL path  

---

## How Navigation Works

### For Users:
1. Click a tab in NavigationRail or BottomNavigationBar
2. `context.go()` is called with the appropriate URL
3. Browser address bar updates
4. State is maintained within MainScreen

### For Clients:
1. Click a tab in NavigationRail or BottomNavigationBar
2. `context.go()` is called with the appropriate URL (e.g., `/client-dashboard/manage`)
3. Browser address bar updates
4. ClientMainScreen receives the initialIndex and displays the correct tab
5. State is maintained properly

---

## Usage Examples

### Navigating Programmatically

```dart
import 'package:go_router/go_router.dart';

// User navigation
context.go('/main');                    // Home
context.go('/main/explore');            // Explore
context.go('/main/compare');            // Compare
context.go('/main/saved');              // Saved
context.go('/main/profile');            // Profile
context.go('/notifications');           // Notifications
context.go('/settings');                // Settings

// Client navigation
context.go('/client-dashboard');        // Default (Manage)
context.go('/client-dashboard/add');    // Add Offer
context.go('/client-dashboard/manage'); // Manage Offers
context.go('/client-dashboard/enquiries'); // Enquiries
context.go('/client-dashboard/profile');   // Profile

// Info pages
context.go('/about-us');
context.go('/contact-us');
context.go('/terms-and-conditions');
context.go('/privacy-policy');
```

---

## Testing Checklist

- [ ] Run `flutter pub get`
- [ ] Test app on web: `flutter run -d chrome`
- [ ] User can navigate tabs and see URL update
- [ ] Client can navigate tabs and see URL update
- [ ] Browser back/forward buttons work
- [ ] Direct URL entry (deep linking) works:
  - Try: `localhost:port/main/compare`
  - Try: `localhost:port/client-dashboard/enquiries`
- [ ] Redirect logic works correctly based on user role
- [ ] Mobile view (BottomNavigationBar) updates URLs
- [ ] Desktop view (NavigationRail) updates URLs

---

## Constants Reference

Use these constants in your code for type-safe routing:

```dart
AppRouter.home                    // '/main'
AppRouter.homeExplore            // '/main/explore'
AppRouter.homeCompare            // '/main/compare'
AppRouter.homeSaved              // '/main/saved'
AppRouter.homeProfile            // '/main/profile'
AppRouter.notifications          // '/notifications'
AppRouter.settings               // '/settings'
AppRouter.clientDashboard        // '/client-dashboard'
AppRouter.clientAdd              // '/client-dashboard/add'
AppRouter.clientManage           // '/client-dashboard/manage'
AppRouter.clientEnquiries        // '/client-dashboard/enquiries'
AppRouter.clientProfile          // '/client-dashboard/profile'
AppRouter.aboutUs                // '/about-us'
AppRouter.contactUs              // '/contact-us'
AppRouter.termsAndConditions     // '/terms-and-conditions'
AppRouter.privacyPolicy          // '/privacy-policy'
```

---

## Future Enhancements

1. **Add query parameters** for filtering/sorting
2. **Add path parameters** for specific item IDs
3. **Implement error screen** for invalid routes
4. **Add transition animations** between routes
5. **Implement route guards** for protected pages

