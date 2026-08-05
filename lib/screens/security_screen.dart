import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../services/biometric_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _loadingBio = true;
  BiometricCapability _cap = const BiometricCapability(
    hasFace: false,
    hasFingerprint: false,
    hasWeak: false,
    hasStrong: false,
    deviceSupported: false,
    canCheck: false,
  );

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final cap = await BiometricService.instance.capability;
    if (!mounted) return;
    setState(() {
      _cap = cap;
      _loadingBio = false;
    });
  }

  Future<bool> _confirmWithPin(String title) async {
    final pinController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Enter your PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (AppState().verifyPin(pinController.text.trim())) {
                Navigator.pop(ctx, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _onBiometricToggle(bool enable) async {
    if (!_cap.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No Face ID or fingerprint set up on this device. Add one in system settings.',
          ),
        ),
      );
      return;
    }

    final label = _cap.label;
    if (enable) {
      final pinOk = await _confirmWithPin('Confirm PIN to enable $label');
      if (!pinOk || !mounted) return;

      final passed = await BiometricService.instance.authenticate(
        reason: 'Confirm with face or fingerprint to unlock Kwanpa Susu',
      );
      if (!mounted) return;

      if (!passed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Face unlock didn’t complete. Make sure face unlock is set up in phone Settings, then try again.',
            ),
          ),
        );
        return;
      }

      AppState().setBiometricEnabled(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label unlock enabled'),
          backgroundColor: AppColors.forestGreen,
        ),
      );
    } else {
      final pinOk = await _confirmWithPin('Confirm PIN to disable $label');
      if (!pinOk || !mounted) return;
      AppState().setBiometricEnabled(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label unlock disabled')),
      );
    }
  }

  Future<void> _testBiometric() async {
    if (!AppState().biometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turn on biometric unlock first')),
      );
      return;
    }
    final ok = await BiometricService.instance.authenticate(
      reason: 'Test face or fingerprint unlock',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'It worked — you can unlock with face or fingerprint.'
            : 'Biometric failed. Check device settings and try again.'),
        backgroundColor: ok ? AppColors.forestGreen : const Color(0xFFD32F2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final on = state.biometricEnabled && _cap.isAvailable;

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
                  _biometricHero(on),
                  const SizedBox(height: 12),
                  if (!_loadingBio) _capabilityChips(),
                  const SizedBox(height: 24),
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
                          icon: Icons.security_rounded,
                          title: 'Biometric Unlock',
                          subtitle: _loadingBio
                              ? 'Checking this device…'
                              : _cap.isAvailable
                                  ? 'Use ${_cap.label} to sign in faster'
                                  : 'Not available — set up face or fingerprint in system settings',
                          trailing: Switch.adaptive(
                            value: on,
                            activeThumbColor: AppColors.vibrantGreen,
                            activeTrackColor: AppColors.darkGreenAccent,
                            onChanged: _loadingBio
                                ? null
                                : (val) => _onBiometricToggle(val),
                          ),
                        ),
                        if (on) ...[
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF5F5F5)),
                          _tile(
                            icon: Icons.verified_user_outlined,
                            title: 'Test unlock',
                            subtitle: 'Try face or fingerprint on this phone',
                            trailing: const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textSecondary),
                            onTap: _testBiometric,
                          ),
                        ],
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
                      'If your phone has both face unlock and fingerprint, either one works. We never store your face or fingerprint — only your phone’s secure hardware does.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
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

  Widget _capabilityChips() {
    final chips = <Widget>[];
    if (_cap.hasFace || _cap.hasWeak) {
      chips.add(_chip(Icons.face_retouching_natural_rounded, _cap.faceLabel));
    }
    if (_cap.hasFingerprint || _cap.hasStrong) {
      chips.add(_chip(Icons.fingerprint_rounded, 'Fingerprint'));
    }
    if (chips.isEmpty && _cap.isAvailable) {
      chips.add(_chip(Icons.face_retouching_natural_rounded, 'Face unlock'));
      chips.add(_chip(Icons.fingerprint_rounded, 'Fingerprint'));
    }
    if (chips.isEmpty) {
      chips.add(_chip(Icons.info_outline_rounded, 'None enrolled'));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.darkGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _biometricHero(bool on) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: on
              ? const [Color(0xFF0B3D2E), AppColors.darkGreen]
              : const [Color(0xFF2E3A36), Color(0xFF1A2421)],
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 56,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: _heroIcon(Icons.face_retouching_natural_rounded),
                ),
                Positioned(
                  left: 22,
                  child: _heroIcon(Icons.fingerprint_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loadingBio ? 'Checking…' : _cap.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _loadingBio
                      ? 'Looking for Face ID and fingerprint…'
                      : on
                          ? 'On — unlock with face or fingerprint'
                          : _cap.isAvailable
                              ? _cap.detail
                              : 'This device has no biometrics enrolled',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.vibrantGreen.withValues(alpha: 0.22),
        border: Border.all(color: const Color(0xFF0B3D2E), width: 2),
      ),
      child: Icon(icon, color: AppColors.vibrantGreen, size: 20),
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
