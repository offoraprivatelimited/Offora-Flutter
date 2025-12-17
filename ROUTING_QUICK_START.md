# Quick Start: URL Routing Implementation

## What Changed?

Your app now shows different URLs for different pages:
- **User Home**: `offora.in/main`
- **User Explore**: `offora.in/main/explore`
- **User Compare**: `offora.in/main/compare`
- **User Saved**: `offora.in/main/saved`
- **User Profile**: `offora.in/main/profile`
- **Client Dashboard Tabs**: `offora.in/client-dashboard/add`, `manage`, `enquiries`, `profile`

## Installation

1. Run: `flutter pub get`

## Testing

```bash
# On Windows (PowerShell)
flutter run -d chrome

# Or
flutter run -d windows
```

Then:
1. Click on different tabs in the main dashboard
2. Watch the URL change in the browser address bar
3. Try the browser back/forward buttons

## Files Modified

| File | Changes |
|------|---------|
| `pubspec.yaml` | Added `go_router: ^14.0.0` |
| `lib/main.dart` | Uses `MaterialApp.router` with GoRouter |
| `lib/core/router/app_router.dart` | Complete route configuration (NEW) |
| `lib/screens/main_screen.dart` | Added `context.go()` for tab navigation |
| `lib/client/screens/main/client_main_screen.dart` | Added `initialIndex` param & `context.go()` |

## URL Routes at a Glance

### User Routes
```
/main                    → Home
/main/explore           → Explore
/main/compare           → Compare
/main/saved             → Saved
/main/profile           → Profile
/notifications          → Notifications
/settings               → Settings
/offer-details          → Offer Details
```

### Client Routes
```
/client-dashboard       → Manage Offers (default)
/client-dashboard/add   → Add Offer
/client-dashboard/manage → Manage Offers
/client-dashboard/enquiries → Enquiries
/client-dashboard/profile   → Profile
/new-offer              → New Offer Form
/manage-offers          → Manage Offers Screen
```

### Info Routes
```
/about-us               → About Us
/contact-us             → Contact Us
/terms-and-conditions   → Terms & Conditions
/privacy-policy         → Privacy Policy
```

### Auth Routes
```
/                       → Auth Gate
/role-selection         → Role Selection
/splash                 → Splash Screen
/onboarding             → Onboarding
/auth                   → Auth Screen
/user-login             → User Login
/profile-complete       → Profile Complete
/client-login           → Client Login
/client-signup          → Client Signup
/pending-approval       → Pending Approval
/rejection              → Rejection
```

## How It Works

### When User Clicks a Tab:
1. NavigationRail/BottomNavigationBar calls `context.go('/main/explore')`
2. GoRouter updates the browser URL
3. Browser address bar shows `offora.in/main/explore`
4. The screen content updates to show the Explore tab

### When User Enters URL Directly:
1. User enters `offora.in/main/compare` in browser
2. GoRouter matches the route and loads the Compare page
3. MainScreen loads with Compare tab selected

## Browser History

✅ Back button works - goes to previous URL
✅ Forward button works - goes to next URL
✅ URL persistence - reload page keeps the current route
✅ Deep linking - can bookmark specific pages

## Troubleshooting

### Issue: App doesn't compile
**Solution**: Run `flutter pub get` to install `go_router`

### Issue: URLs not updating
**Solution**: Make sure you're using `context.go()` not `Navigator.push()`

### Issue: Can't navigate to a specific URL
**Solution**: Check that the path matches exactly in the router configuration

## Need to Add More Routes?

Edit `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/your-new-path',
  name: 'your-route-name',
  builder: (context, state) => const YourScreen(),
),
```

## Questions?

Refer to `COMPLETE_ROUTING_GUIDE.md` for detailed documentation.

