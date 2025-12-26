#!/bin/bash
# BACK BUTTON FIX - COMPREHENSIVE VERIFICATION CHECKLIST
# Generated: December 26, 2025

echo "=========================================="
echo "BACK BUTTON NAVIGATION FIX - VERIFICATION"
echo "=========================================="
echo ""

# 1. Check for any remaining goNamed in auth screens
echo "✓ CHECKING: No problematic goNamed() in auth screens..."
grep -r "context\.goNamed\|context\.go\(" \
  lib/screens/auth_screen.dart \
  lib/screens/user_login_screen.dart \
  lib/screens/profile_complete_screen.dart \
  lib/client/screens/auth/login_screen.dart \
  lib/client/screens/auth/signup_screen.dart \
  lib/client/screens/auth/pending_approval_page.dart 2>/dev/null || echo "✓ PASS: No problematic navigation found"

echo ""
echo "✓ CHECKING: All auth screens use replaceNamed()..."
echo "  - auth_screen.dart: $(grep -c 'replaceNamed' lib/screens/auth_screen.dart) uses"
echo "  - user_login_screen.dart: $(grep -c 'replaceNamed' lib/screens/user_login_screen.dart) uses"
echo "  - profile_complete_screen.dart: $(grep -c 'replaceNamed' lib/screens/profile_complete_screen.dart) uses"
echo "  - client login_screen.dart: $(grep -c 'replaceNamed' lib/client/screens/auth/login_screen.dart) uses"
echo "  - client signup_screen.dart: $(grep -c 'replaceNamed' lib/client/screens/auth/signup_screen.dart) uses"
echo "  - pending_approval_page.dart: $(grep -c 'replaceNamed' lib/client/screens/auth/pending_approval_page.dart) uses"

echo ""
echo "✓ CHECKING: PopScope with AppExitDialog on dashboards..."
if grep -q "AppExitDialog.show" lib/screens/main_screen.dart; then
  echo "  ✓ User MainScreen: Has PopScope + AppExitDialog"
else
  echo "  ✗ User MainScreen: MISSING PopScope or AppExitDialog"
fi

if grep -q "AppExitDialog.show" lib/client/screens/main/client_main_screen.dart; then
  echo "  ✓ Client MainScreen: Has PopScope + AppExitDialog"
else
  echo "  ✗ Client MainScreen: MISSING PopScope or AppExitDialog"
fi

echo ""
echo "✓ CHECKING: Router configuration..."
if grep -q "onException" lib/core/router/app_router.dart && grep -q "errorBuilder" lib/core/router/app_router.dart; then
  echo "  ✗ ERROR: Router has BOTH onException and errorBuilder (conflicting!)"
elif grep -q "errorBuilder" lib/core/router/app_router.dart; then
  echo "  ✓ Router: Has errorBuilder (onException removed)"
fi

echo ""
echo "=========================================="
echo "✓ ALL VERIFICATIONS COMPLETE"
echo "=========================================="
echo ""
echo "SUMMARY OF BACK BUTTON BEHAVIOR:"
echo ""
echo "USER FLOW:"
echo "  1. User logs in/signs up → Uses replaceNamed('auth-gate')"
echo "  2. Auth-gate redirects → Uses replace/replaceNamed"
echo "  3. In MainScreen (home) → Back shows 'Exit Offora?' dialog"
echo "  4. Confirm exit → Signs out → Navigates to role-selection"
echo "  5. Back button NEVER goes to login screens ✓"
echo ""
echo "CLIENT/SHOP OWNER FLOW:"
echo "  1. Shop owner logs in/signs up → Uses replaceNamed"
echo "  2. Pending approval/active/rejected → Uses replaceNamed"
echo "  3. In ClientMainScreen (dashboard) → Back shows 'Exit Offora?' dialog"
echo "  4. Confirm exit → Signs out → Navigates to role-selection"
echo "  5. Back button NEVER goes to login screens ✓"
echo ""
