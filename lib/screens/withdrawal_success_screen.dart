import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WithdrawalSuccessScreen extends StatefulWidget {
  final double amount;
  final String destinationAccount;
  final String transactionId;
  final String dateTimeStr;

  const WithdrawalSuccessScreen({
    super.key,
    this.amount = 500.00,
    this.destinationAccount = 'MTN MoMo (024 123 4567)',
    this.transactionId = 'TXN-88492041',
    this.dateTimeStr = 'Today, 5:16 PM',
  });

  @override
  State<WithdrawalSuccessScreen> createState() => _WithdrawalSuccessScreenState();
}

class _WithdrawalSuccessScreenState extends State<WithdrawalSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Spring bounce scale animation for the mark icon/logo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Continuous subtle pulsing for background glow halo & particles
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
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
            // Decorative Top Gradient Blob (Figma 4:1700)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 320,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.vibrantGreen.withValues(alpha: 0.20),
                      AppColors.vibrantGreen.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Canvas
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),

                        // Animated Mark Icon / Logo Section (matching user request)
                        Center(
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Animated Pulsing Outer Ring
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.vibrantGreen.withValues(alpha: 0.30),
                                    ),
                                  ),
                                ),
                                // Surrounding Burst Particles
                                ..._buildParticleBurst(),

                                // Core Dark Green Icon Anchor with Spring Scale Animation
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.darkGreen,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.darkGreen.withValues(alpha: 0.25),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: AppColors.vibrantGreen,
                                        size: 44,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Heading 1 - Identity & Context (Figma 4:1712)
                        const Text(
                          'Withdrawal Successful!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'GH₵ ${widget.amount.toStringAsFixed(2)} has been sent to\nyour mobile account.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Section - Details Bento Grid (Level 1 Cards) (Figma 4:1725)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                              _buildBentoRow(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Withdrawal Amount',
                                value: 'GH₵ ${widget.amount.toStringAsFixed(2)}',
                                isBold: true,
                                valueColor: AppColors.forestGreen,
                              ),
                              const Divider(height: 24, color: Color(0xFFF0F2F1)),
                              _buildBentoRow(
                                icon: Icons.phone_android_rounded,
                                label: 'Destination Account',
                                value: widget.destinationAccount,
                              ),
                              const Divider(height: 24, color: Color(0xFFF0F2F1)),
                              _buildBentoRow(
                                icon: Icons.receipt_long_outlined,
                                label: 'Transaction Reference',
                                value: widget.transactionId,
                              ),
                              const Divider(height: 24, color: Color(0xFFF0F2F1)),
                              _buildBentoRow(
                                icon: Icons.access_time_rounded,
                                label: 'Date & Time',
                                value: widget.dateTimeStr,
                              ),
                              const Divider(height: 24, color: Color(0xFFF0F2F1)),
                              _buildBentoRow(
                                icon: Icons.verified_user_outlined,
                                label: 'Processing Fee',
                                value: 'Free (GH₵ 0.00)',
                                valueColor: AppColors.darkGreen,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Section - Actions Bar (Bottom Anchored) (Figma 4:1702)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Button - Primary Action (Vibrant Lime / Deep Forest Green) (Figma 4:1704)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.vibrantGreen,
                            elevation: 3,
                            shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Back to Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Button - Secondary Action (Outline Transparent) (Figma 4:1707)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Receipt downloaded successfully')),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, color: AppColors.darkGreen, size: 20),
                          label: const Text(
                            'Download Receipt',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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

  List<Widget> _buildParticleBurst() {
    final List<Map<String, double>> particles = [
      {'top': 8, 'left': 30},
      {'top': 12, 'right': 35},
      {'bottom': 16, 'left': 24},
      {'bottom': 14, 'right': 28},
      {'top': 60, 'left': 8},
      {'top': 65, 'right': 10},
    ];

    return particles.map((p) {
      return Positioned(
        top: p['top'],
        bottom: p['bottom'],
        left: p['left'],
        right: p['right'],
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.vibrantGreen,
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBentoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.vibrantGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.darkGreenAccent, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.darkGreen,
          ),
        ),
      ],
    );
  }
}
