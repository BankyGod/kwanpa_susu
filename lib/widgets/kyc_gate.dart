import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

/// Returns true if KYC is verified. Otherwise shows a sheet and offers Verify.
Future<bool> ensureKycVerified(
  BuildContext context, {
  required String actionLabel,
}) async {
  if (AppState().isKycVerified) return true;

  final go = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      final pending = AppState().isKycPending;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                pending
                    ? Icons.hourglass_top_rounded
                    : Icons.badge_outlined,
                color: AppColors.darkGreen,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                pending
                    ? 'Verification in progress'
                    : 'Verify your Ghana Card',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pending
                    ? 'Your Ghana Card check is still pending. You’ll be able to $actionLabel once it’s verified.'
                    : 'To $actionLabel, verify your Ghana Card. This protects your savings and meets Ghana identity rules.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    pending ? 'View status' : 'Verify Ghana Card',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreenAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Not now',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (go == true && context.mounted) {
    await Navigator.of(context).pushNamed('/verify_ghana_card');
    return AppState().isKycVerified;
  }
  return false;
}
