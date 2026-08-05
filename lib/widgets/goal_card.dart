import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class GoalCard extends StatelessWidget {
  final SusuGoal goal;
  final VoidCallback? onTap;
  final bool featured;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercentage;
    final percent = (progress * 100).toInt();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: featured
                ? AppColors.vibrantGreen.withValues(alpha: 0.4)
                : AppColors.notchColor.withValues(alpha: 0.3),
            width: featured ? 1.5 : 1,
          ),
          gradient: featured
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.vibrantGreen.withValues(alpha: 0.06),
                    Colors.white,
                  ],
                )
              : null,
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: featured
                        ? const Color(0xFFE8F8EA)
                        : const Color(0xFFF4F6F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goal.icon, color: AppColors.forestGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: goal.isLocked
                              ? const Color(0xFFFFF8E1)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          goal.isLocked ? 'Locked' : 'Flexible',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: goal.isLocked
                                ? const Color(0xFFF57F17)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (goal.isAchieved)
                  const Icon(Icons.check_circle, color: AppColors.forestGreen),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GHS ${goal.currentSaved.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  '/ GHS ${goal.targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percent% Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: goal.isLocked
                        ? const Color(0xFFF57F17)
                        : AppColors.darkGreen,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      goal.isLocked
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      goal.lockDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isLocked
                      ? const Color(0xFFF57F17)
                      : AppColors.vibrantGreen,
                ),
              ),
            ),
            if (goal.isAutoSave) ...[
              const SizedBox(height: 10),
              Text(
                'Auto-save GHS ${goal.autoSaveAmount.toStringAsFixed(0)} · ${goal.frequency}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
