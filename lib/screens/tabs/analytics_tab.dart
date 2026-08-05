import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final factors = state.analyticsWeekly
            ? state.weeklySpendFactors
            : state.monthlySpendFactors;
        final labels = state.analyticsWeekly
            ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
            : const [
                'J',
                'F',
                'M',
                'A',
                'M',
                'J',
                'J',
                'A',
                'S',
                'O',
                'N',
                'D'
              ];
        final highlightIndex = factors.indexOf(
          factors.reduce((a, b) => a > b ? a : b),
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.darkGreen, AppColors.cardGradientEnd],
                  ),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.vibrantGreen,
                      child: Icon(Icons.electric_bolt_rounded,
                          color: AppColors.darkGreenAccent, size: 32),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'The Impulse Saver',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.notchColor.withValues(alpha: 0.3),
                  ),
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
                              _toggleChip(
                                'Weekly',
                                selected: state.analyticsWeekly,
                                onTap: () => state.setAnalyticsWeekly(true),
                              ),
                              _toggleChip(
                                'Monthly',
                                selected: !state.analyticsWeekly,
                                onTap: () => state.setAnalyticsWeekly(false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(factors.length, (i) {
                        return _bar(
                          labels[i],
                          factors[i],
                          highlighted: i == highlightIndex,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_down_rounded,
                              color: AppColors.forestGreen, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: state.analyticsWeekly
                                    ? 'You spent '
                                    : 'This month you spent ',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                children: const [
                                  TextSpan(
                                    text: '15% less',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.forestGreen,
                                    ),
                                  ),
                                  TextSpan(text: ' than last period.'),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.notchColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outlined,
                            color: AppColors.forestGreen, size: 20),
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
                    Text.rich(
                      TextSpan(
                        text: 'Save ',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.darkGreen),
                        children: [
                          TextSpan(
                            text:
                                'GHS ${state.goals.isNotEmpty ? state.goals.first.autoSaveAmount.toStringAsFixed(0) : '50'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          const TextSpan(
                              text: ' more this week to reach your goal early!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/deposit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                            Icon(Icons.arrow_forward_rounded,
                                color: AppColors.darkGreenAccent, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (state.budgetCategories.any((c) => c.isOverBudget || c.progress > 0.8))
                ...state.budgetCategories
                    .where((c) => c.isOverBudget || c.progress > 0.8)
                    .take(1)
                    .map(
                      (c) => Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.notchColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: c.color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(c.icon, color: c.color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    c.isOverBudget
                                        ? 'This category is over budget. Consider cutting back this week.'
                                        : 'This category is higher than usual. Consider adjusting soon.',
                                    style: const TextStyle(
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
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _toggleChip(String label,
      {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
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
          width: 14,
          height: 70 * factor,
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
            fontSize: 12,
            fontWeight: highlighted ? FontWeight.bold : FontWeight.w500,
            color: highlighted ? AppColors.darkGreen : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
