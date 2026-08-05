import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.vibrantGreen, width: 2.5),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.darkGreen,
                            AppColors.cardGradientEnd
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          state.initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.vibrantGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_android_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          state.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _kycChip(context, state),
                  ],
                ),
              ),
              if (!state.isKycVerified) ...[
                const SizedBox(height: 16),
                _kycBanner(context, state),
              ],
              const SizedBox(height: 24),
              _section(
                'Account Settings',
                [
                  _item(
                    icon: Icons.badge_outlined,
                    title: 'Ghana Card verification',
                    subtitle: state.kycStatusLabel,
                    trailing: Icon(
                      state.isKycVerified
                          ? Icons.verified_rounded
                          : Icons.chevron_right_rounded,
                      size: 20,
                      color: state.isKycVerified
                          ? AppColors.forestGreen
                          : AppColors.textSecondary,
                    ),
                    onTap: () => Navigator.of(context)
                        .pushNamed('/verify_ghana_card'),
                  ),
                  _item(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    subtitle: 'Update your details',
                    onTap: () =>
                        Navigator.of(context).pushNamed('/personal_info'),
                  ),
                  _item(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage MoMo & Bank cards',
                    onTap: () =>
                        Navigator.of(context).pushNamed('/payment_methods'),
                  ),
                  _item(
                    icon: Icons.lock_outline_rounded,
                    title: 'Security',
                    subtitle: 'Change PIN, enable Biometrics',
                    onTap: () => Navigator.of(context).pushNamed('/security'),
                  ),
                  _item(
                    icon: Icons.groups_outlined,
                    title: 'Group Susu',
                    subtitle: 'Save together',
                    onTap: () => Navigator.of(context).pushNamed('/groups'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _section(
                'Preferences',
                [
                  _item(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Alerts and updates',
                    trailing: Switch.adaptive(
                      value: state.notificationsEnabled,
                      activeThumbColor: AppColors.vibrantGreen,
                      activeTrackColor: AppColors.darkGreenAccent,
                      onChanged: state.setNotificationsEnabled,
                    ),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/notifications'),
                  ),
                  _item(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    subtitle: state.language,
                    onTap: () => _pickLanguage(context, state),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _section(
                'Support & Legal',
                [
                  _item(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Help Center coming soon. Email support@kwanpasusu.app'),
                        ),
                      );
                    },
                  ),
                  _item(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Privacy Policy: We never sell your financial data.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    state.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/signin', (route) => false);
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: Color(0xFFD32F2F), size: 20),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'App Version 2.1.0 (Build 45)',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _kycChip(BuildContext context, AppState state) {
    final verified = state.isKycVerified;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/verify_ghana_card'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: verified
              ? AppColors.vibrantGreen.withValues(alpha: 0.2)
              : const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              verified ? Icons.verified_rounded : Icons.warning_amber_rounded,
              size: 14,
              color: verified ? AppColors.forestGreen : const Color(0xFFE65100),
            ),
            const SizedBox(width: 4),
            Text(
              verified ? 'Ghana Card verified' : state.kycStatusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    verified ? AppColors.forestGreen : const Color(0xFFE65100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kycBanner(BuildContext context, AppState state) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).pushNamed('/verify_ghana_card'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.notchColor.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.badge_outlined,
                    color: AppColors.darkGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verify Ghana Card',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.isKycPending
                          ? 'Verification is in progress'
                          : 'Required for withdrawals and Group Susu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _pickLanguage(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final options = [
          'English (UK)',
          'English (US)',
          'Twi',
          'French',
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Choose Language',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkGreen,
                ),
              ),
              ...options.map(
                (lang) => ListTile(
                  title: Text(lang),
                  trailing: state.language == lang
                      ? const Icon(Icons.check, color: AppColors.forestGreen)
                      : null,
                  onTap: () {
                    state.setLanguage(lang);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
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
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            )
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppColors.textSecondary),
    );
  }
}
