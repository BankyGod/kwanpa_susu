import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/activity_row.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  void _showTxSheet(
    BuildContext context, {
    required String title,
    required List<TransactionItem> items,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        'No spending in this period.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => ActivityRow(item: items[i]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final amounts = state.activeSpendingAmounts;
        final labels = state.activeSpendingLabels;
        final maxAmount = amounts.fold<double>(0, (a, b) => a > b ? a : b);
        final highlightIndex =
            maxAmount <= 0 ? -1 : amounts.indexOf(maxAmount);
        final change = state.spendChangePercent;
        final spentLess = change != null && change >= 0;
        final goal = state.primaryActiveGoal;
        final topCategories = state.spendingCategoryBreakdown.take(3).toList();
        final period = state.analyticsWeekly ? 'week' : 'month';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        letterSpacing: -0.5,
                      ),
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
                        _chip('Week', state.analyticsWeekly,
                            () => state.setAnalyticsWeekly(true)),
                        _chip('Month', !state.analyticsWeekly,
                            () => state.setAnalyticsWeekly(false)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                state.analyticsPersonaTitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Core answers: spent / saved / compare
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.notchColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _kpi(
                            'Spent',
                            'GHS ${state.periodSpending.toStringAsFixed(0)}',
                            const Color(0xFFE65100),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.notchColor.withValues(alpha: 0.4),
                        ),
                        Expanded(
                          child: _kpi(
                            'Saved',
                            'GHS ${state.periodSavings.toStringAsFixed(0)}',
                            AppColors.forestGreen,
                          ),
                        ),
                        if (!state.analyticsWeekly) ...[
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.notchColor.withValues(alpha: 0.4),
                          ),
                          Expanded(
                            child: _kpi(
                              'Of income',
                              '${(state.savingsVsIncomeRate * 100).toStringAsFixed(0)}%',
                              const Color(0xFF0066CC),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            change == null
                                ? Icons.info_outline_rounded
                                : spentLess
                                    ? Icons.trending_down_rounded
                                    : Icons.trending_up_rounded,
                            size: 18,
                            color: change == null
                                ? AppColors.textSecondary
                                : spentLess
                                    ? AppColors.forestGreen
                                    : const Color(0xFFD32F2F),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              change == null
                                  ? 'Need more history to compare periods.'
                                  : spentLess
                                      ? '${change.abs().toStringAsFixed(0)}% less than last $period'
                                      : '${change.abs().toStringAsFixed(0)}% more than last $period',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.notchColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spending',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap a bar to see transactions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (!state.hasAnalyticsSpendData)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No spending yet this period.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(amounts.length, (i) {
                          final factor =
                              maxAmount <= 0 ? 0.0 : amounts[i] / maxAmount;
                          return GestureDetector(
                            onTap: () => _showTxSheet(
                              context,
                              title: '${labels[i]} · GHS ${amounts[i].toStringAsFixed(0)}',
                              items: state.spendingTransactionsForBucket(i),
                            ),
                            child: _bar(
                              labels[i],
                              factor.clamp(0.08, 1.0),
                              highlighted: i == highlightIndex,
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),

              // Top categories only (max 3)
              if (topCategories.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.notchColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...topCategories.map((row) {
                        return InkWell(
                          onTap: () => _showTxSheet(
                            context,
                            title: row.name,
                            items: state
                                .spendingTransactionsForCategory(row.name),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(row.icon, size: 18, color: row.color),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    row.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                ),
                                Text(
                                  'GHS ${row.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              // One tip + one action
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.analyticsSmartTip,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGreen,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (goal != null) {
                            Navigator.of(context).pushNamed(
                              '/goal_detail',
                              arguments: goal.id,
                            );
                          } else {
                            AppState().openSavingsTab();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          goal != null ? 'Open goal' : 'Go to Savings',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreenAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // At most one budget alert
              if (state.budgetCategories
                  .any((c) => c.isOverBudget || c.isNearLimit)) ...[
                const SizedBox(height: 12),
                Builder(
                  builder: (_) {
                    final c = state.budgetCategories.firstWhere(
                      (x) => x.isOverBudget || x.isNearLimit,
                    );
                    return InkWell(
                      onTap: () => AppState().openBudgetTab(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.notchColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(c.icon, color: c.color, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.isOverBudget
                                    ? '${c.name} is over budget'
                                    : '${c.name} is near its limit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _kpi(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppColors.darkGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _bar(String label, double factor, {bool highlighted = false}) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 64 * factor,
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.vibrantGreen
                : AppColors.darkGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: highlighted ? FontWeight.bold : FontWeight.w500,
            color: highlighted ? AppColors.darkGreen : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
