import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/bounce_button.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/primary_button.dart';
import 'budget_screen.dart';

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
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Profile Avatar & Greeting (matching screenshot)
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.vibrantGreen, width: 2),
                          gradient: const LinearGradient(
                            colors: [AppColors.darkGreen, AppColors.cardGradientEnd],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'KM',
                            style: TextStyle(
                              color: AppColors.vibrantGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hello,',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Kwame',
                            style: TextStyle(
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

                  // Notification Bell with Red Badge Dot
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.darkGreen,
                          size: 26,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 1.5),
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
      body: ListenableBuilder(
        listenable: AppState(),
        builder: (context, _) {
          return IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeDashboardTab(),
              const BudgetScreen(),
              _buildSavingsDashboardTab(),
              _buildAnalyticsGroupsTab(),
              _buildUserProfileTab(),
            ],
          );
        },
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Budget'),
                _buildNavItem(2, Icons.savings_rounded, Icons.savings_outlined, 'Savings'),
                _buildNavItem(3, Icons.analytics_rounded, Icons.analytics_outlined, 'Analytics'),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vibrantGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              size: 20,
              color: isSelected ? AppColors.darkGreenAccent : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.darkGreenAccent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboardTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance Hero Card (matching screenshot)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkGreen,
                  AppColors.cardGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA3B3A9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'GHS ${(AppState().totalBalance + 8250.00).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Wallet',
                          style: TextStyle(fontSize: 11, color: Color(0xFFA3B3A9)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GHS ${AppState().totalBalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Locked Savings',
                          style: TextStyle(fontSize: 11, color: Color(0xFFA3B3A9)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'GHS 8,250.00',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3 Quick Action Cards Row (Deposit, Withdraw, New Goal) matching screenshot
          Row(
            children: [
              Expanded(
                child: _buildSquareActionButton(
                  icon: Icons.south_rounded,
                  label: 'Deposit',
                  isPrimaryGreen: true,
                  onTap: () => Navigator.of(context).pushNamed('/deposit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSquareActionButton(
                  icon: Icons.north_rounded,
                  label: 'Withdraw',
                  isPrimaryGreen: false,
                  onTap: () => Navigator.of(context).pushNamed('/withdraw'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSquareActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'New Goal',
                  isPrimaryGreen: false,
                  onTap: () => Navigator.of(context).pushNamed('/create_goal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Budget Card (matching screenshot)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Budget',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Monthly Budget: 65% used',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                // 65% Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vibrantGreen),
                  ),
                ),
                const SizedBox(height: 16),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spent', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('GHS 1,950', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Remaining', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('GHS 1,050', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity Card (matching screenshot)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Activity 1: Melcom Supermarket (-GHS 250.00)
                Builder(
                  builder: (context) {
                    final loading = AppState().isLoadingTransactions;
                    if (loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: ShimmerCardPlaceholder(height: 60),
                      );
                    } else {
                      return _buildActivityRowItem(
                        title: 'Melcom Supermarket',
                        subtitle: 'Today, 14:30',
                        amount: '-GHS 250.00',
                        isCredit: false,
                        icon: Icons.shopping_bag_outlined,
                        iconBgColor: const Color(0xFFFFEBEE),
                        iconColor: const Color(0xFFD32F2F),
                      );
                    }
                  },
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFF5F5F5)),

                // Activity 2: Salary Deposit (+GHS 4,500.00)
                Builder(
                  builder: (context) {
                    final loading = AppState().isLoadingTransactions;
                    if (loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: ShimmerCardPlaceholder(height: 60),
                      );
                    } else {
                      return _buildActivityRowItem(
                        title: 'Salary Deposit',
                        subtitle: 'Yesterday',
                        amount: '+GHS 4,500.00',
                        isCredit: true,
                        icon: Icons.account_balance_wallet_outlined,
                        iconBgColor: const Color(0xFFE8F8EA),
                        iconColor: AppColors.forestGreen,
                      );
                    }
                  },
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFF5F5F5)),

                // Activity 3: ECG Prepaid (-GHS 120.00)
                Builder(
                  builder: (context) {
                    final loading = AppState().isLoadingTransactions;
                    if (loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: ShimmerCardPlaceholder(height: 60),
                      );
                    } else {
                      return _buildActivityRowItem(
                        title: 'ECG Prepaid',
                        subtitle: '12 Oct',
                        amount: '-GHS 120.00',
                        isCredit: false,
                        icon: Icons.electric_bolt_outlined,
                        iconBgColor: const Color(0xFFFFF8E1),
                        iconColor: const Color(0xFFF57F17),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSquareActionButton({
    required IconData icon,
    required String label,
    required bool isPrimaryGreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPrimaryGreen ? AppColors.vibrantGreen : const Color(0xFFEFEFEF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isPrimaryGreen ? AppColors.darkGreenAccent : AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRowItem({
    required String title,
    required String subtitle,
    required String amount,
    required bool isCredit,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isCredit ? AppColors.forestGreen : AppColors.darkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsDashboardTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header Title & Subtitle (matching screenshot)
          const Text(
            'My Goals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your savings progress and upcoming milestones.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),

          // Primary + Create New Goal Button (matching screenshot)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: PrimaryButton(
              onPressed: () => Navigator.of(context).pushNamed('/create_goal'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: AppColors.darkGreenAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Create New Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Goal Card 1: New House Deposit (Featured Highlight Card)
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('/goal_detail'),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.vibrantGreen.withValues(alpha: 0.4), width: 1.5),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.vibrantGreen.withValues(alpha: 0.06),
                  Colors.white,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F8EA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cottage_outlined, color: AppColors.forestGreen, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'New House Deposit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Locked',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF57F17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 20),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Saved', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text(
                          'GHS 45,000',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Target Amount', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text(
                          'GHS 100,000',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '45% Completed',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF57F17)),
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text('Ends Dec 2026', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Gold Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF57F17)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

          // Goal Card 2: Child's Education (Radial Circular Progress Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Radial Progress Indicator
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: 0.75,
                          strokeWidth: 8,
                          backgroundColor: Color(0xFFEEEEEE),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantGreen),
                        ),
                      ),
                      const Text(
                        '75%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Child's Education",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'GHS 15,000 / GHS 20,000',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ends Aug 2024',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Goal Card 3: Emergency Fund (Compact Row Card)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: Color(0xFFD32F2F), size: 20),
                    ),
                    const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Emergency Fund',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text(
                      'GHS 5,000',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                    ),
                    Text(
                      ' / GHS 10,000',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Flexible',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    const Text(
                      '50%',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Goal Card 4: Dubai Trip 2025 (Progress Bar Card)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flight_outlined, color: Color(0xFF00796B), size: 20),
                    ),
                    const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dubai Trip 2025',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text(
                      'GHS 2,400',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                    ),
                    Text(
                      ' / GHS 12,000',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('20% Completed', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Row(
                      children: [
                        Icon(Icons.lock_open_rounded, size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text('Unlocked', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.20,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGroupsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. The Impulse Saver (Personality Hero Card matching screenshot)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkGreen,
                  AppColors.cardGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.vibrantGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.electric_bolt_rounded,
                    color: AppColors.darkGreenAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The Impulse Saver',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You tend to save in bursts! Harness this energy to hit your goals faster.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA3B3A9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Spending Trends Card with Weekly/Monthly Selector (matching screenshot)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Spending Trends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Weekly',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: const Text(
                              'Monthly',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Days of Week Bar Chart Representation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildWeeklyBar('Mon', 0.4),
                    _buildWeeklyBar('Tue', 0.55),
                    _buildWeeklyBar('Wed', 0.35),
                    _buildWeeklyBar('Thu', 0.85, isHighlighted: true),
                    _buildWeeklyBar('Fri', 0.6),
                    _buildWeeklyBar('Sat', 0.7),
                    _buildWeeklyBar('Sun', 0.3),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 14),

                // Highlight Banner Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_down_rounded, color: AppColors.forestGreen, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'You spent ',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: '15% less',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                              ),
                              TextSpan(text: ' than last Thursday.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. SMART TIP Card (matching screenshot)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outlined, color: AppColors.forestGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'SMART TIP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text.rich(
                  TextSpan(
                    text: 'Save ',
                    style: TextStyle(fontSize: 14, color: AppColors.darkGreen),
                    children: [
                      TextSpan(
                        text: 'GHS 50',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                      ),
                      TextSpan(text: ' more this week to reach your goal early!'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/deposit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Move to Savings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreenAccent,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: AppColors.darkGreenAccent, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Dining Out Category Card (matching screenshot)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.restaurant_rounded, color: Color(0xFFD32F2F), size: 22),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dining Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'This category is higher than usual. Consider cooking at home this weekend.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeeklyBar(String day, double factor, {bool isHighlighted = false}) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 70 * factor,
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.vibrantGreen : AppColors.darkGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.darkGreen : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // User Avatar Header Section (matching screenshot)
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.vibrantGreen, width: 2.5),
                    gradient: const LinearGradient(
                      colors: [AppColors.darkGreen, AppColors.cardGradientEnd],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen.withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'KM',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vibrantGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kwame Mensah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_android_rounded, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '+233 54 123 4567',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Group 1: Account Settings (matching screenshot)
          _buildProfileGroupSection(
            sectionTitle: 'Account Settings',
            children: [
              _buildGroupedProfileItem(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                subtitle: 'Update your details',
                onTap: () => Navigator.of(context).pushNamed('/personal_info'),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
              _buildGroupedProfileItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage MoMo & Bank cards',
                onTap: () => Navigator.of(context).pushNamed('/payment_methods'),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
              _buildGroupedProfileItem(
                icon: Icons.lock_outline_rounded,
                title: 'Security',
                subtitle: 'Change PIN, enable Biometrics',
                onTap: () => Navigator.of(context).pushNamed('/security'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Group 2: Preferences (matching screenshot)
          _buildProfileGroupSection(
            sectionTitle: 'Preferences',
            children: [
              _buildGroupedProfileItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Alerts and updates',
                trailingWidget: Switch.adaptive(
                  value: true,
                  activeThumbColor: AppColors.vibrantGreen,
                  activeTrackColor: AppColors.darkGreenAccent,
                  onChanged: (val) {},
                ),
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
              _buildGroupedProfileItem(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English (UK)',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Group 3: Support & Legal (matching screenshot)
          _buildProfileGroupSection(
            sectionTitle: 'Support & Legal',
            children: [
              _buildGroupedProfileItem(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
              _buildGroupedProfileItem(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Log Out Action Button (matching screenshot)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/signin'),
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 20),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Footer App Version Text
          const Text(
            'App Version 2.1.0 (Build 45)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileGroupSection({
    required String sectionTitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.darkGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailingWidget ??
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
    );
  }
}
