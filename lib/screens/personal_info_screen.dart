import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _ghanaCardController;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    final state = AppState();
    _fullNameController = TextEditingController(text: state.fullName);
    _phoneController = TextEditingController(text: state.phone);
    _emailController = TextEditingController(text: state.email);
    _ghanaCardController = TextEditingController(text: state.ghanaCardId);
    _dobController = TextEditingController(text: state.dateOfBirth);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ghanaCardController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _openVerify() async {
    await Navigator.of(context).pushNamed('/verify_ghana_card');
    if (!mounted) return;
    final state = AppState();
    setState(() {
      _ghanaCardController.text = state.ghanaCardId;
      _fullNameController.text = state.fullName;
      if (state.dateOfBirth.isNotEmpty) {
        _dobController.text = state.dateOfBirth;
      }
    });
  }

  void _saveChanges() {
    AppState().updateProfile(
      name: _fullNameController.text,
      phoneNumber: _phoneController.text,
      emailAddress: _emailController.text,
      idNumber: _ghanaCardController.text,
      dob: _dobController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personal Information updated successfully!'),
        backgroundColor: AppColors.forestGreen,
      ),
    );
    Navigator.of(context).pop();
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
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Personal Info',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Photo Section (Figma 4:994)
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 104,
                              height: 104,
                              child: Stack(
                                children: [
                                  // Profile Avatar
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.darkGreen,
                                      border: Border.all(color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.initials,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.vibrantGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Edit Profile Photo Button Badge (Figma 4:1002)
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Change profile picture...')),
                                        );
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.darkGreen,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.15),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.camera_alt_rounded,
                                            color: AppColors.vibrantGreen,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                            GestureDetector(
                              onTap: _openVerify,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    verified
                                        ? Icons.verified_rounded
                                        : Icons.badge_outlined,
                                    color: verified
                                        ? AppColors.forestGreen
                                        : const Color(0xFFE65100),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    verified
                                        ? 'Verified Member • Ghana Card Active'
                                        : state.kycStatusLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: verified
                                          ? AppColors.textSecondary
                                              .withValues(alpha: 0.9)
                                          : const Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Fields (Figma 4:1006)
                      _buildFormField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildFormField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _buildFormField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildFormField(
                        controller: _ghanaCardController,
                        label: 'Ghana Card (ID)',
                        icon: Icons.badge_outlined,
                        isReadOnly: true,
                        trailing: GestureDetector(
                          onTap: _openVerify,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: verified
                                  ? AppColors.vibrantGreen
                                      .withValues(alpha: 0.2)
                                  : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  verified
                                      ? Icons.check_circle_rounded
                                      : Icons.arrow_forward_rounded,
                                  color: verified
                                      ? AppColors.forestGreen
                                      : const Color(0xFFE65100),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  verified ? 'Verified' : 'Verify',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: verified
                                        ? AppColors.forestGreen
                                        : const Color(0xFFE65100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!verified) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _openVerify,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.darkGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Verify Ghana Card',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildFormField(
                        controller: _dobController,
                        label: 'Date of Birth',
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // Primary Bottom Save Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGreen,
                    elevation: 3,
                    shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isReadOnly = false,
    Widget? trailing,
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
            color: isReadOnly ? const Color(0xFFF8F9FA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.4)),
          ),
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              suffixIcon: trailing != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: trailing,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
