import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import 'budget_screen.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/home_dashboard_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/savings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AppState().simulateLoading();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.vibrantGreen, width: 2),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.darkGreen,
                                  AppColors.cardGradientEnd
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                state.initials,
                                style: const TextStyle(
                                  color: AppColors.vibrantGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Hello,',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                state.firstName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamed('/notifications'),
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.darkGreen,
                              size: 26,
                            ),
                          ),
                          if (state.unreadNotificationCount > 0)
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.background, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              HomeDashboardTab(),
              BudgetScreen(embedded: true),
              SavingsTab(),
              AnalyticsTab(),
              ProfileTab(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 68,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _nav(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                    _nav(1, Icons.receipt_long_rounded,
                        Icons.receipt_long_outlined, 'Budget'),
                    _nav(2, Icons.savings_rounded, Icons.savings_outlined,
                        'Savings'),
                    _nav(3, Icons.analytics_rounded, Icons.analytics_outlined,
                        'Analytics'),
                    _nav(4, Icons.person_rounded, Icons.person_outline_rounded,
                        'Profile'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _nav(int index, IconData active, IconData inactive, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.vibrantGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? active : inactive,
              size: 20,
              color: selected
                  ? AppColors.darkGreenAccent
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected
                    ? AppColors.darkGreenAccent
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
