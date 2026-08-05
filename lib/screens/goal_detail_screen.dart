import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';

class GoalDetailScreen extends StatelessWidget {
  final String? goalId;

  const GoalDetailScreen({super.key, this.goalId});

  void _contribute(BuildContext context, SusuGoal goal) {
    final controller =
        TextEditingController(text: goal.autoSaveAmount.toStringAsFixed(2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.isLocked ? 'Contribute to Locked Goal' : 'Contribute',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              if (goal.isLocked) ...[
                const SizedBox(height: 8),
                const Text(
                  'Funds stay locked until the unlock date. Early withdrawal is not available.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Wallet: GHS ${AppState().totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (GHS)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text.trim());
                    if (amount == null) return;
                    final ok = AppState().contributeToGoal(goal.id, amount);
                    Navigator.pop(ctx);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppState().lastError ?? 'Contribution failed',
                          ),
                        ),
                      );
                      return;
                    }
                    final updated = AppState().goalById(goal.id);
                    if (updated != null && updated.isAchieved) {
                      Navigator.of(context).pushReplacementNamed('/goal_achieved');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added GHS ${amount.toStringAsFixed(2)} to ${goal.title}',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Confirm Contribution',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreenAccent,
                    ),
                  ),
                ),
              ),
            ],
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
        final id = goalId ??
            (ModalRoute.of(context)?.settings.arguments as String?) ??
            (state.goals.isNotEmpty ? state.goals.first.id : null);
        final goal = id == null ? null : state.goalById(id);

        if (goal == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.darkGreen),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: EmptyState(
              icon: Icons.flag_outlined,
              title: 'Goal not found',
              message: 'This savings goal may have been removed.',
              actionLabel: 'Back to Goals',
              onAction: () => Navigator.of(context).maybePop(),
            ),
          );
        }

        final progress = goal.progressPercentage;
        final percentage = (progress * 100).toInt();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkGreen, size: 22),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Goal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.darkGreen,
                                AppColors.cardGradientEnd
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      goal.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFB74D)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFFFFB74D)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          goal.isLocked
                                              ? Icons.lock_rounded
                                              : Icons.lock_open_rounded,
                                          size: 12,
                                          color: const Color(0xFFFFB74D),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          goal.isLocked
                                              ? 'Time-Locked'
                                              : 'Unlocked',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFB74D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                goal.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'GHS ${goal.currentSaved.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.vibrantGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.15),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.vibrantGreen),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$percentage% Completed · Target ${goal.lockDate}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFA3B3A9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                'Frequency',
                                goal.frequency,
                                Icons.repeat_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoCard(
                                'Auto-save',
                                goal.isAutoSave
                                    ? 'GHS ${goal.autoSaveAmount.toStringAsFixed(0)}'
                                    : 'Off',
                                Icons.autorenew_rounded,
                              ),
                            ),
                          ],
                        ),
                        if (goal.isLocked) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'This goal is locked until the unlock date. You can keep contributing, but funds cannot be withdrawn early.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFF57F17),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: goal.isAchieved
                          ? () => Navigator.of(context)
                              .pushNamed('/goal_achieved')
                          : () => _contribute(context, goal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        goal.isAchieved ? 'View Achievement' : 'Contribute Now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreenAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.forestGreen),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
