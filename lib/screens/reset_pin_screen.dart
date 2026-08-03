import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ResetPinScreen extends StatefulWidget {
  const ResetPinScreen({super.key});

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String _selectedCountryCode = '+233';

  final List<Map<String, String>> _countryCodes = [
    {'flag': '🇬🇭', 'code': '+233', 'name': 'Ghana'},
    {'flag': '🇳🇬', 'code': '+234', 'name': 'Nigeria'},
    {'flag': '🇰🇪', 'code': '+254', 'name': 'Kenya'},
    {'flag': '🇿🇦', 'code': '+27', 'name': 'South Africa'},
    {'flag': '🇬🇧', 'code': '+44', 'name': 'UK'},
    {'flag': '🇺🇸', 'code': '+1', 'name': 'USA'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendResetCode() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushNamed(
        '/verify',
        arguments: '$_selectedCountryCode ${_phoneController.text}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkGreen, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Decorative Ambient Blur (Top Left Mint)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFBCEDD7).withValues(alpha: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBCEDD7).withValues(alpha: 0.8),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Background Decorative Ambient Blur (Bottom Right Lime)
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.vibrantGreen.withValues(alpha: 0.35),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.vibrantGreen.withValues(alpha: 0.45),
                    blurRadius: 80,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // Main Recovery Container
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo / Branding
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkGreen.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 32,
                        color: AppColors.vibrantGreen,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Reset Your PIN',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Enter your registered phone number to receive a verification code.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Glassmorphism Card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF0B3D2E).withValues(alpha: 0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkGreen.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Phone Number Label
                            const Text(
                              'PHONE NUMBER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Phone Number Input Container
                            Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.notchColor, width: 1),
                              ),
                              child: Row(
                                children: [
                                  // Country Code Dropdown
                                  Container(
                                    height: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F5),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(11),
                                        bottomLeft: Radius.circular(11),
                                      ),
                                      border: Border(
                                        right: BorderSide(color: AppColors.notchColor, width: 1),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Map<String, String>>(
                                        value: _countryCodes.firstWhere(
                                          (element) => element['code'] == _selectedCountryCode,
                                          orElse: () => _countryCodes.first,
                                        ),
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                        onChanged: (newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedCountryCode = newValue['code']!;
                                            });
                                          }
                                        },
                                        items: _countryCodes.map((country) {
                                          return DropdownMenuItem<Map<String, String>>(
                                            value: country,
                                            child: Text(
                                              '${country['flag']} ${country['code']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF191C1D),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),

                                  // Number Input
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      style: const TextStyle(fontSize: 15, color: Color(0xFF191C1D)),
                                      decoration: const InputDecoration(
                                        hintText: '54 123 4567',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: InputBorder.none,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        if (value.trim().length < 8) {
                                          return 'Please enter a valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Primary Action Button ("Send Reset Code")
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleSendResetCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.vibrantGreen,
                                  elevation: 0,
                                  shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Send Reset Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGreenAccent,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: AppColors.darkGreenAccent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Secondary Back Link
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Remember your PIN?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
