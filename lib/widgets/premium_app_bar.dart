import 'package:flutter/material.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogo;
  final Widget? leading;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLogo = false,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: leading,
      actions: actions,
      titleSpacing: 0,
      title: Row(
        children: [
          if (showLogo) ...[
            SizedBox(
              height: 28,
              child: Image.asset(
                'assets/images/logo/original/Text_without_logo_without_background.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}
