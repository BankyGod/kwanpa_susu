import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/shimmer_loader.dart';

class SavingsTab extends StatelessWidget {
  const SavingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();

        if (state.hasLoadError) {
          return ErrorState(
            message: state.lastError ?? 'Could not load goals.',
            onRetry: state.retryLoad,
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: PrimaryButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/create_goal'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
              if (state.isLoadingGoals)
                const Column(
                  children: [
                    ShimmerCardPlaceholder(height: 160),
                    SizedBox(height: 12),
                    ShimmerCardPlaceholder(height: 140),
                  ],
                )
              else if (state.goals.isEmpty)
                EmptyState(
                  icon: Icons.savings_outlined,
                  title: 'No savings goals',
                  message:
                      'Create a goal to lock funds, auto-save, and track progress.',
                  actionLabel: 'Create Goal',
                  onAction: () =>
                      Navigator.of(context).pushNamed('/create_goal'),
                )
              else
                ...List.generate(state.goals.length, (index) {
                  final goal = state.goals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GoalCard(
                      goal: goal,
                      featured: index == 0,
                      onTap: () => Navigator.of(context).pushNamed(
                        '/goal_detail',
                        arguments: goal.id,
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
