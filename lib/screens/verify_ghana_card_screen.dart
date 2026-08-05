import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class VerifyGhanaCardScreen extends StatefulWidget {
  const VerifyGhanaCardScreen({super.key});

  @override
  State<VerifyGhanaCardScreen> createState() => _VerifyGhanaCardScreenState();
}

class _VerifyGhanaCardScreenState extends State<VerifyGhanaCardScreen> {
  late final TextEditingController _cardController;
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  bool _selfieCaptured = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final state = AppState();
    _cardController = TextEditingController(text: state.ghanaCardId);
    _nameController = TextEditingController(text: state.fullName);
    _dobController = TextEditingController(text: state.dateOfBirth);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    DateTime initial = DateTime(now.year - 25, now.month, now.day);
    final text = _dobController.text.trim();
    final parts = text.split(RegExp(r'[/\s]+'));
    if (parts.length >= 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null && y > 1900) {
        initial = DateTime(y, m, d);
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
    }
  }

  Future<void> _captureSelfie() async {
    // Frontend placeholder — camera / liveness hooks into NIA later.
    setState(() => _selfieCaptured = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selfie captured (demo). Live face check comes with backend.'),
        backgroundColor: AppColors.forestGreen,
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final ok = await AppState().submitGhanaCardVerification(
      cardNumber: _cardController.text,
      name: _nameController.text,
      dob: _dobController.text,
      selfieCaptured: _selfieCaptured,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ghana Card verified'),
          content: const Text(
            'Your identity is verified. You can withdraw and join Group Susu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    final err = AppState().lastError ?? 'Verification failed.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err), backgroundColor: const Color(0xFFD32F2F)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final verified = state.isKycVerified;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkGreen),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Verify Ghana Card',
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statusBanner(state),
                        const SizedBox(height: 20),
                        const Text(
                          'Identity details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Must match your Ghana Card exactly. Backend will confirm with NIA.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _field(
                          label: 'Ghana Card number',
                          controller: _cardController,
                          hint: 'GHA-123456789-1',
                          enabled: !verified && !_submitting,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\-]'),
                            ),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        _field(
                          label: 'Full name (as on card)',
                          controller: _nameController,
                          hint: 'First Middle Last',
                          enabled: !verified && !_submitting,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          label: 'Date of birth',
                          controller: _dobController,
                          hint: 'DD / MM / YYYY',
                          enabled: !verified && !_submitting,
                          readOnly: true,
                          onTap: verified || _submitting ? null : _pickDob,
                          suffix: Icons.calendar_today_outlined,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Face check',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'A live selfie will be matched against NIA biometrics when the API is connected.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _selfieCard(verified),
                        if (state.kycStatus == 'failed' &&
                            state.kycFailReason != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              state.kycFailReason!,
                              style: const TextStyle(
                                color: Color(0xFFC62828),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Demo tip: use a card ending in -1 to pass, or -0 to fail.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!verified)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantGreen,
                          disabledBackgroundColor:
                              AppColors.vibrantGreen.withValues(alpha: 0.5),
                          elevation: 3,
                          shadowColor:
                              AppColors.vibrantGreen.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.darkGreenAccent,
                                ),
                              )
                            : Text(
                                state.isKycPending
                                    ? 'Checking with NIA…'
                                    : 'Submit for verification',
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

  Widget _statusBanner(AppState state) {
    Color bg;
    Color fg;
    IconData icon;
    String title;
    String subtitle;

    switch (state.kycStatus) {
      case 'verified':
        bg = AppColors.vibrantGreen.withValues(alpha: 0.2);
        fg = AppColors.forestGreen;
        icon = Icons.verified_rounded;
        title = 'Verified';
        subtitle = state.kycVerifiedAt != null
            ? 'Your Ghana Card is active on this account.'
            : 'Identity confirmed.';
        break;
      case 'pending':
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF9A825);
        icon = Icons.hourglass_top_rounded;
        title = 'Pending';
        subtitle = 'Waiting for verification result…';
        break;
      case 'failed':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFD32F2F);
        icon = Icons.error_outline_rounded;
        title = 'Failed';
        subtitle = 'Fix your details and try again.';
        break;
      default:
        bg = const Color(0xFFF4F6F5);
        fg = AppColors.darkGreen;
        icon = Icons.badge_outlined;
        title = 'Not verified';
        subtitle = 'Required before withdrawals and Group Susu.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selfieCard(bool verified) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: verified || _submitting ? null : _captureSelfie,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _selfieCaptured
                  ? AppColors.forestGreen
                  : AppColors.notchColor.withValues(alpha: 0.5),
              width: _selfieCaptured ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selfieCaptured
                      ? AppColors.vibrantGreen.withValues(alpha: 0.25)
                      : const Color(0xFFF4F6F5),
                ),
                child: Icon(
                  _selfieCaptured
                      ? Icons.check_rounded
                      : Icons.camera_alt_outlined,
                  color: AppColors.darkGreen,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selfieCaptured
                    ? 'Selfie ready'
                    : 'Tap to capture selfie',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Demo capture — no camera permission needed yet',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.notchColor.withValues(alpha: 0.4)),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            readOnly: readOnly || onTap != null,
            onTap: onTap,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB0BEC5),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: suffix != null
                  ? Icon(suffix, color: AppColors.textSecondary, size: 18)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
