import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/activity_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_loader.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkGreen, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: AppState(),
        builder: (context, _) {
          final state = AppState();

          if (state.hasLoadError) {
            return ErrorState(
              message: state.lastError ?? 'Failed to load transactions.',
              onRetry: state.retryLoad,
            );
          }

          if (state.isLoadingTransactions) {
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) => const ShimmerCardPlaceholder(height: 64),
            );
          }

          final txs = state.transactions;
          if (txs.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              message:
                  'Your deposits, withdrawals, and goal contributions will show up here.',
              actionLabel: 'Make a Deposit',
              onAction: () => Navigator.of(context).pushNamed('/deposit'),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: txs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.notchColor.withValues(alpha: 0.3),
                  ),
                ),
                child: ActivityRow(item: txs[index]),
              );
            },
          );
        },
      ),
    );
  }
}
