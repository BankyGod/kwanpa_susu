import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final items = state.notifications;
        final unread = state.unreadNotificationCount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.darkGreen, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            actions: [
              if (unread > 0)
                TextButton(
                  onPressed: state.markAllNotificationsRead,
                  child: const Text(
                    'Mark all',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
            ],
          ),
          body: !state.notificationsEnabled
              ? EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Notifications off',
                  message:
                      'Turn on notifications in Profile to receive savings alerts.',
                  actionLabel: 'Enable',
                  onAction: () => state.setNotificationsEnabled(true),
                )
              : items.isEmpty
                  ? EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'All caught up',
                      message: 'New deposits, goals, and group updates will appear here.',
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = items[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            state.markNotificationRead(n.id);
                            if (n.route != null) {
                              Navigator.of(context).pushNamed(
                                n.route!,
                                arguments: n.routeArgs,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: n.isUnread
                                  ? AppColors.vibrantGreen.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.notchColor
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: n.bgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(n.icon, color: n.color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkGreen,
                                              ),
                                            ),
                                          ),
                                          if (n.isUnread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.forestGreen,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.subtitle,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        n.time,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
