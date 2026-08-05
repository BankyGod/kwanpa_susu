import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkGreen, size: 22),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Authentication',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.notchColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.lock_reset_rounded,
                          title: 'Change PIN',
                          subtitle: 'Update your 4-digit security PIN',
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textSecondary),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/reset_pin'),
                        ),
                        const Divider(
                            height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
                        _tile(
                          icon: Icons.fingerprint_rounded,
                          title: 'Biometric Unlock',
                          subtitle: 'Use Face ID or Fingerprint to sign in',
                          trailing: Switch.adaptive(
                            value: state.biometricEnabled,
                            activeThumbColor: AppColors.vibrantGreen,
                            activeTrackColor: AppColors.darkGreenAccent,
                            onChanged: (val) {
                              state.setBiometricEnabled(val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(val
                                      ? 'Biometric Unlock enabled'
                                      : 'Biometric Unlock disabled'),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(
                            height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
                        _tile(
                          icon: Icons.phonelink_lock_rounded,
                          title: 'Two-Factor Prompts',
                          subtitle: 'Extra confirmation for withdrawals',
                          trailing: Switch.adaptive(
                            value: state.twoFactorEnabled,
                            activeThumbColor: AppColors.vibrantGreen,
                            activeTrackColor: AppColors.darkGreenAccent,
                            onChanged: state.setTwoFactorEnabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Demo PIN is stored only on this device. Default PIN: 1234',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
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
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: trailing,
    );
  }
}
