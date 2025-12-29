import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return SafeArea(
      child: CustomScrollView(
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
                        'assets/images/logo/original/Text_without_logo_without_background.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (user == null)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'Sign in required',
                message: 'Please sign in to view notifications',
              ),
            )
          else
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkBlue,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.error_outline,
                      title: 'Oops!',
                      message: 'Could not load notifications',
                    ),
                  );
                }

                final notifications = snapshot.data?.docs ?? [];

                if (notifications.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.notifications_none,
                      title: 'No notifications',
                      message: 'You\'re all caught up!',
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notif = notifications[index];
                      final data = notif.data() as Map<String, dynamic>;

                      return _NotificationTile(
                        title: data['title'] ?? 'Notification',
                        message: data['message'] ?? '',
                        timestamp: (data['createdAt'] as Timestamp?)?.toDate(),
                        isRead: data['isRead'] ?? false,
                        type: data['type'] ?? 'info',
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('notifications')
                              .doc(notif.id)
                              .update({'isRead': true});
                        },
                      );
                    },
                    childCount: notifications.length,
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final DateTime? timestamp;
  final bool isRead;
  final String type;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.message,
    this.timestamp,
    required this.isRead,
    required this.type,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (type) {
      case 'offer':
        return Icons.local_offer;
      case 'approval':
        return Icons.check_circle;
      case 'rejection':
        return Icons.cancel;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case 'offer':
        return AppColors.brightGold;
      case 'approval':
        return Colors.green;
      case 'rejection':
        return Colors.red;
      case 'system':
        return AppColors.darkBlue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.darkBlue.withAlpha(13),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconColor().withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlue,
                                  ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.brightGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(timestamp!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }
}
