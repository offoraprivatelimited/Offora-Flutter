# URL Routing Implementation Guide

## Overview
Your app has been updated to use **GoRouter** for proper URL management. Now different pages will display different URLs in the browser's address bar.

## Changes Made

### 1. Added `go_router` Package
- Updated `pubspec.yaml` to include `go_router: ^14.0.0`

### 2. Created New Router Configuration
- **File**: `lib/core/router/app_router.dart`
- Centralized all routing logic using GoRouter
- Defines URL routes for each page:
  - `/main` - Home tab
  - `/main/explore` - Explore tab
  - `/main/compare` - Compare tab
  - `/main/saved` - Saved offers tab
  - `/main/profile` - Profile tab
  - `/about-us` - About Us page
  - `/contact-us` - Contact Us page
  - `/terms-and-conditions` - Terms page
  - `/privacy-policy` - Privacy Policy page
  - Plus all authentication and client routes

### 3. Updated `main.dart`
- Changed from `MaterialApp` to `MaterialApp.router`
- Integrated with GoRouter using `routerConfig: AppRouter.router`
- Simplified imports and removed old route definitions

### 4. Updated `main_screen.dart`
- Added `go_router` import
- Modified `onDestinationSelected` callback in NavigationRail to update URL when tabs are tapped:
  - Calls `context.go()` with appropriate URL path
  - Updates URL bar to show `/main`, `/main/explore`, `/main/compare`, `/main/saved`, or `/main/profile`
- Applied same URL navigation to bottom navigation bar for mobile view

## How It Works

### Desktop Navigation
When you click on a tab in the NavigationRail:
1. The tab index changes locally (visual feedback)
2. The URL is updated via `context.go('/main/explore')`, etc.
3. Browser address bar shows the new URL

### Mobile Navigation
Same behavior applies to the CustomBottomNavBar for smaller screens.

### Redirect Logic
- Handles authentication redirects
- Redirects shopowners to client dashboard
- Redirects regular users to main screen
- Keeps unauthenticated users on auth gate

## URL Examples

After these changes, users will see:

| Page | URL |
|------|-----|
| Home | `offora.in/main` |
| Explore | `offora.in/main/explore` |
| Compare | `offora.in/main/compare` |
| Saved Offers | `offora.in/main/saved` |
| Profile | `offora.in/main/profile` |
| About Us | `offora.in/about-us` |
| Contact | `offora.in/contact-us` |
| Terms | `offora.in/terms-and-conditions` |
| Privacy | `offora.in/privacy-policy` |

## Next Steps

1. Run `flutter pub get` to install the `go_router` package
2. Test the application on web:
   ```bash
   flutter run -d chrome
   ```
3. Navigate between tabs and verify URLs update in the browser address bar
4. Test back/forward buttons in the browser to ensure proper navigation history
5. Test deep linking by directly entering URLs like `offora.in/main/compare`

## Migration Notes

- GoRouter automatically handles:
  - Browser back/forward buttons
  - Direct URL entry (deep linking)
  - URL history management
  - Query parameters (if needed later)

- If you had other navigation using `Navigator.pushNamed()`, consider updating those to use `context.go()` or `context.push()` for consistency

## Benefits

✅ **SEO Friendly** - Different URLs for different pages  
✅ **Deep Linking** - Users can bookmark and share specific pages  
✅ **Browser History** - Back/forward buttons work correctly  
✅ **Modern Web App** - Matches user expectations for web applications  
✅ **Better Analytics** - Each page has a unique, trackable URL  

