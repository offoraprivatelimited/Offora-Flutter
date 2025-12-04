import 'package:flutter/material.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showMenu;
  final VoidCallback? onMenuTap;

  const PremiumAppBar({
    super.key,
    this.title,
    this.showMenu = true,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F477D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showMenu)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: onMenuTap ??
                      () {
                        Scaffold.of(context).openDrawer();
                      },
                ),
              const SizedBox(width: 16),
              Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SizedBox(
                  height: 28,
                  child: Image.asset(
                    'assets/images/logo/original/Text_without_logo_without_background.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (title != null) ...[
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
