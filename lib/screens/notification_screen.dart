import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _markAllAsRead = false;

  final List<Map<String, dynamic>> _todayNotifications = [
    {
      'id': '1',
      'title': 'Emergency Fund Goal Reached 80%!',
      'subtitle': 'Great job! You deposited GH₵ 50.00 today toward your savings target.',
      'time': '2h ago',
      'icon': Icons.emoji_events_rounded,
      'color': const Color(0xFFC9A900),
      'bgColor': const Color(0xFFFFF9C4),
      'isUnread': true,
    },
    {
      'id': '2',
      'title': 'Daily Susu Deposit Received',
      'subtitle': 'GH₵ 50.00 credited to your Susu account from MTN MoMo.',
      'time': '5h ago',
      'icon': Icons.south_west_rounded,
      'color': AppColors.forestGreen,
      'bgColor': const Color(0xFFE8F8EA),
      'isUnread': false,
    },
  ];

  final List<Map<String, dynamic>> _earlierNotifications = [
    {
      'id': '3',
      'title': 'Accra Traders Payout Update',
      'subtitle': 'You are #3 in line for the September 1st payout pool of GH₵ 12,000.00.',
      'time': 'Yesterday',
      'icon': Icons.groups_rounded,
      'color': const Color(0xFFE65100),
      'bgColor': const Color(0xFFFFF3E0),
      'isUnread': false,
    },
    {
      'id': '4',
      'title': 'Successful Device Login',
      'subtitle': 'New login detected from Kwanpa Susu Mobile App on Android device.',
      'time': 'Aug 2, 2026',
      'icon': Icons.shield_rounded,
      'color': const Color(0xFF0066CC),
      'bgColor': const Color(0xFFE6F4FF),
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkGreen, size: 20),
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.darkGreen, size: 22),
                onPressed: () {},
              ),
              if (!_markAllAsRead)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.vibrantGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header (Activity Title & Mark all as read)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _markAllAsRead = true;
                        for (var item in _todayNotifications) {
                          item['isUnread'] = false;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _markAllAsRead ? 'All Read ✓' : 'Mark all read',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Time Group: TODAY Header
              const Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // Today Notifications List
              ..._todayNotifications.map((item) => _buildNotificationTile(item)),

              const SizedBox(height: 24),

              // Time Group: EARLIER Header
              const Text(
                'EARLIER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // Earlier Notifications List
              ..._earlierNotifications.map((item) => _buildNotificationTile(item)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> item) {
    final bool isUnread = item['isUnread'] == true && !_markAllAsRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppColors.vibrantGreen.withValues(alpha: 0.5)
              : AppColors.notchColor.withValues(alpha: 0.3),
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: isUnread ? 0.06 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item['bgColor'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.forestGreen,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
