import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DepositErrorScreen extends StatefulWidget {
  final double amount;
  final String sourceAccount;
  final String errorMessage;

  const DepositErrorScreen({
    super.key,
    this.amount = 150.00,
    this.sourceAccount = 'MTN MoMo (024 123 4567)',
    this.errorMessage = 'Mobile Money prompt timed out or PIN was entered incorrectly.',
  });

  @override
  State<DepositErrorScreen> createState() => _DepositErrorScreenState();
}

class _DepositErrorScreenState extends State<DepositErrorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Warm Red Ambient Radial Background Glow (Figma 4:2197)
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              height: 320,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [
                      const Color(0xFFFFCDD2).withValues(alpha: 0.45),
                      const Color(0xFFFFEBEE).withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Area
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // Animated Error Hero Badge
                        Center(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing Red Halo Ring
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFFCDD2).withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                // Inner Red Circle Anchor
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFD32F2F),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 46,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Headline & Error Message (Figma 4:2199 & 4:2202)
                        const Text(
                          'Deposit Failed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text.rich(
                            TextSpan(
                              text: "We couldn't process your deposit of ",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: 'GH₵ ${widget.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                const TextSpan(
                                  text: '.\nYour mobile money provider timed out or the request was cancelled.',
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Transaction Details Card (Figma 4:2206)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFCDD2).withValues(alpha: 0.8)),
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
                              _buildCardRow(
                                label: 'Attempted Amount',
                                value: 'GH₵ ${widget.amount.toStringAsFixed(2)}',
                                isBold: true,
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF5F5F5)),
                              _buildCardRow(
                                label: 'Source Account',
                                value: widget.sourceAccount,
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF5F5F5)),
                              _buildCardRow(
                                label: 'Status',
                                value: 'Failed / Timed Out',
                                valueColor: const Color(0xFFD32F2F),
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Action Buttons (Figma 4:2223)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Re-try deposit
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.vibrantGreen,
                            elevation: 3,
                            shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, color: AppColors.darkGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text(
                          'Cancel & Return Home',
                          style: TextStyle(
                            fontSize: 15,
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
          ],
        ),
      ),
    );
  }

  Widget _buildCardRow({
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.darkGreen,
          ),
        ),
      ],
    );
  }
}
