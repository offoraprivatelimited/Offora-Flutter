import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 96,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkBlue,
                      AppColors.darkBlue.withAlpha(200),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Image.asset(
                        'images/logo/original/Text_without_logo_without_background.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  const _SectionHeader(title: 'Account'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () {
                          Navigator.pushNamed(context, '/profile-complete');
                        },
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () {
                          _showComingSoon(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Preferences Section
                  const _SectionHeader(title: 'Preferences'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Get notified about new offers',
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            _showComingSoon(context);
                          },
                          // `activeColor` is deprecated; use `activeThumbColor`
                          activeThumbColor: AppColors.brightGold,
                        ),
                        onTap: null,
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.location_on_outlined,
                        title: 'Location Services',
                        subtitle: 'Find offers near you',
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            _showComingSoon(context);
                          },
                          activeThumbColor: AppColors.brightGold,
                        ),
                        onTap: null,
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {
                          _showComingSoon(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Support Section
                  const _SectionHeader(title: 'Support'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'FAQs and support articles',
                        onTap: () {
                          _showComingSoon(context);
                        },
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.feedback_outlined,
                        title: 'Send Feedback',
                        subtitle: 'Help us improve Offora',
                        onTap: () async {
                          final uri = Uri(
                            scheme: 'mailto',
                            path: 'support@offora.com',
                            query: 'subject=Feedback for Offora App',
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.star_outline,
                        title: 'Rate Us',
                        subtitle: 'Share your experience',
                        onTap: () {
                          _showComingSoon(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Legal Section
                  const _SectionHeader(title: 'Legal'),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () {
                          _showComingSoon(context);
                        },
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {
                          _showComingSoon(context);
                        },
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About Offora',
                        subtitle: 'Version 1.0.0',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Offora',
                            applicationVersion: '1.0.0',
                            applicationIcon: Image.asset(
                              'images/logo/original/Logo_without_text_without_background.png',
                              width: 48,
                              height: 48,
                            ),
                            children: [
                              const Text(
                                'Discover amazing local offers and deals, all in one place!',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Logout
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        titleColor: Colors.red,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await context.read<AuthService>().signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, '/user-login');
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.darkBlue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: Colors.grey.shade400)
              : null),
      onTap: onTap,
    );
  }
}
