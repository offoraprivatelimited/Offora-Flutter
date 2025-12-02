import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  static const String routeName = '/role-selection';

  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the colors used in the design
    const darkBlue = Color(0xFF1F477D);
    const brightGold = Color(0xFFF0B84D);
    // const darkerGold = Color(0xFFA3834D); // darkerGold not used in the new structure

    return Scaffold(
      backgroundColor: Colors.white,
      // Wrap the content in a LayoutBuilder for better understanding of available space
      // although the use of Spacers will handle most responsiveness.
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              // Use Column to arrange all elements vertically
              child: Column(
                // Use MainAxisAlignment.center to vertically center the whole block
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // Do not use MainAxisSize.min as we want the Column to fill the screen
                // to allow Spacers to work correctly for non-scrollable layout.
                children: [
                  // --- Dynamic Spacing for Responsiveness (Top) ---
                  const Spacer(flex: 2),

                  // ## Header Section
                  // Logo
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Image.asset(
                      // NOTE: Ensure this image path is correct in your project
                      'images/logo/original/Logo_without_text_without_background.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to Offora',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select how you want to use Offora:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),

                  // --- Dynamic Spacing for Responsiveness (Between Header and User Role) ---
                  const Spacer(flex: 1),

                  // ## User Role (Dominant Card)
                  _SimpleRoleCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shop for Offers',
                    description:
                        'Discover and save the best local deals. Sign in as a user to start exploring.',
                    buttonText: 'Continue as User',
                    accentColor: darkBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/user-login',
                      );
                    },
                  ),

                  // --- Dynamic Spacing for Responsiveness (Between Roles) ---
                  const Spacer(flex: 1),

                  // ## Shop Owner Role (Smaller, Subdued)
                  // The previous Divider is removed for cleaner separation in the new layout
                  // and to better subordinate the secondary role.

                  // Custom widget for the smaller, less dominant role
                  _SubduedRoleButton(
                    title: 'Business Owner',
                    buttonText: 'Continue as Shop Owner',
                    accentColor: brightGold,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/login',
                      );
                    },
                  ),

                  // --- Dynamic Spacing for Responsiveness (Bottom) ---
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Large, Dominant Role Card (For the User Role)
// ----------------------------------------------------
class _SimpleRoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final Color accentColor;
  final VoidCallback onPressed;

  const _SimpleRoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Keep the large Card structure to maintain dominance
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: accentColor.withAlpha(38),
              child: Icon(icon, color: accentColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Small, Subdued Role Button (For the Shop Owner Role)
// ----------------------------------------------------
class _SubduedRoleButton extends StatelessWidget {
  final String title;
  final String buttonText;
  final Color accentColor;
  final VoidCallback onPressed;

  const _SubduedRoleButton({
    required this.title,
    required this.buttonText,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // A smaller, simpler container to make it visually subordinate
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: BorderSide(color: accentColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Keep the button size minimal
        children: [
          const Icon(Icons.store_outlined, size: 20),
          const SizedBox(width: 8),
          Text(
            buttonText,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
