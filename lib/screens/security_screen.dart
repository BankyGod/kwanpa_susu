import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 22),
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
              // Authentication Section (Figma 4:1135)
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
                  border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Change PIN Tile (Figma 4:1139)
                    _buildSecurityTile(
                      icon: Icons.lock_reset_rounded,
                      title: 'Change PIN',
                      subtitle: 'Update your 4-digit security PIN',
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => Navigator.of(context).pushNamed('/reset_pin'),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),

                    // Biometrics Tile (Figma 4:1152)
                    _buildSecurityTile(
                      icon: Icons.fingerprint_rounded,
                      title: 'Biometric Unlock',
                      subtitle: 'Use Face ID or Fingerprint to sign in',
                      trailing: Switch.adaptive(
                        value: _biometricEnabled,
                        activeThumbColor: AppColors.vibrantGreen,
                        activeTrackColor: AppColors.darkGreenAccent,
                        onChanged: (val) {
                          setState(() {
                            _biometricEnabled = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Biometric Unlock enabled' : 'Biometric Unlock disabled'),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),

                    // 2FA Security Tile
                    _buildSecurityTile(
                      icon: Icons.security_rounded,
                      title: 'Two-Factor Authentication',
                      subtitle: 'Require SMS OTP for large transactions',
                      trailing: Switch.adaptive(
                        value: _twoFactorEnabled,
                        activeThumbColor: AppColors.vibrantGreen,
                        activeTrackColor: AppColors.darkGreenAccent,
                        onChanged: (val) {
                          setState(() {
                            _twoFactorEnabled = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Account Protection Section
              const Text(
                'Account Protection',
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
                  border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Active Devices Tile
                    _buildSecurityTile(
                      icon: Icons.devices_rounded,
                      title: 'Active Devices',
                      subtitle: '1 active session • Android Phone',
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Viewing active devices...')),
                        );
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),

                    // Auto-Lock Delay Tile
                    _buildSecurityTile(
                      icon: Icons.timer_outlined,
                      title: 'Auto-Lock App',
                      subtitle: 'Lock immediately upon backgrounding',
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Auto-lock settings...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.vibrantGreen.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: AppColors.darkGreenAccent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
