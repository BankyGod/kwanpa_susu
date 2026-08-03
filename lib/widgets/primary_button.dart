import 'package:flutter/material.dart';
import '../widgets/bounce_button.dart';
import '../theme/app_theme.dart';

/// A reusable primary action button that provides bounce feedback
/// and applies the app's standard styling.
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool enableHaptic;

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.enableHaptic = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BounceButton(
      onPressed: onPressed,
      enableHaptic: enableHaptic,
      child: ElevatedButton(
        onPressed: null, // Handled by BounceButton
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantGreen,
          elevation: 3,
          shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: child,
      ),
    );
  }
}
