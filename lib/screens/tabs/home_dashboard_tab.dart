import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/kyc_gate.dart';
import '../../widgets/activity_row.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();

        if (state.hasLoadError) {
          return ErrorState(
            message: state.lastError ?? 'Could not load dashboard.',
            onRetry: state.retryLoad,
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.darkGreen, AppColors.cardGradientEnd],
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
                      'GHS ${state.totalNetWorth.toStringAsFixed(2)}',
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
                        _balanceStat(
                          'Active Wallet',
                          'GHS ${state.totalBalance.toStringAsFixed(2)}',
                        ),
                        _balanceStat(
                          'Locked Savings',
                          'GHS ${state.lockedSavings.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.south_rounded,
                      label: 'Deposit',
                      primary: true,
                      onTap: () => Navigator.of(context).pushNamed('/deposit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.north_rounded,
                      label: 'Withdraw',
                      primary: false,
                      onTap: () async {
                        final ok = await ensureKycVerified(
                          context,
                          actionLabel: 'withdraw',
                        );
                        if (ok && context.mounted) {
                          Navigator.of(context).pushNamed('/withdraw');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'New Goal',
                      primary: false,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/create_goal'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _budgetCard(context, state),
              const SizedBox(height: 16),
              _analyticsCard(context, state),
              const SizedBox(height: 24),
              _recentActivityCard(context, state),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/groups'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.notchColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.groups_rounded,
                            color: Color(0xFFE65100)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Group Susu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            Text(
                              state.groups.isEmpty
                                  ? 'Save together with friends & family'
                                  : '${state.groups.length} active group${state.groups.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _balanceStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFFA3B3A9))),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
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
                color: primary ? AppColors.vibrantGreen : const Color(0xFFEFEFEF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: primary
                    ? AppColors.darkGreenAccent
                    : AppColors.darkGreen,
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

  Widget _analyticsCard(BuildContext context, AppState state) {
    final change = state.spendChangePercent;
    final spentLess = change != null && change >= 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => AppState().openAnalyticsTab(),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.notchColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.vibrantGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insights_rounded,
                    color: AppColors.darkGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      change == null
                          ? 'Spent GHS ${state.thisWeekSpending.toStringAsFixed(0)} this week · open trends'
                          : spentLess
                              ? '${change.abs().toStringAsFixed(0)}% less than last week · GHS ${state.thisWeekSpending.toStringAsFixed(0)}'
                              : '${change.abs().toStringAsFixed(0)}% more than last week · GHS ${state.thisWeekSpending.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _budgetCard(BuildContext context, AppState state) {
    final over = state.isOverBudget;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => AppState().openBudgetTab(),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: over
                  ? const Color(0xFFD32F2F).withValues(alpha: 0.35)
                  : AppColors.notchColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Budget',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  Row(
                    children: [
                      if (over)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCDD2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Over',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC62828),
                            ),
                          ),
                        ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 22, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${state.budgetPeriodLabel} · ${(state.budgetUsedRatio * 100).clamp(0, 999).toStringAsFixed(0)}% of income used',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: state.budgetUsedPercent,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    over ? const Color(0xFFD32F2F) : AppColors.vibrantGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Spent',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        'GHS ${state.totalExpenses.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: over
                              ? const Color(0xFFD32F2F)
                              : AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(over ? 'Over by' : 'Remaining',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        over
                            ? 'GHS ${(-state.remainingBudget).toStringAsFixed(0)}'
                            : 'GHS ${state.remainingBudget.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: over
                              ? const Color(0xFFD32F2F)
                              : AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentActivityCard(BuildContext context, AppState state) {
    final recent = state.transactions.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
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
                onTap: () =>
                    Navigator.of(context).pushNamed('/transactions'),
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
          if (state.isLoadingTransactions)
            const Column(
              children: [
                ShimmerCardPlaceholder(height: 60),
                SizedBox(height: 10),
                ShimmerCardPlaceholder(height: 60),
              ],
            )
          else if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No activity yet. Make your first deposit.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            ...List.generate(recent.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: i == recent.length - 1 ? 0 : 8),
                child: ActivityRow(
                  item: recent[i],
                  showDivider: i != recent.length - 1,
                ),
              );
            }),
        ],
      ),
    );
  }
}
