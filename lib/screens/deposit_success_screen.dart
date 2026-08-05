import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../utils/receipt_sheet.dart';
import '../utils/money_format.dart';

class DepositSuccessScreen extends StatefulWidget {
  final double amount;
  final String sourceAccount;
  final String transactionId;
  final String dateTimeStr;
  final double newBalance;

  const DepositSuccessScreen({
    super.key,
    this.amount = 500.00,
    this.sourceAccount = 'MTN MoMo',
    this.transactionId = '#KS-88239',
    this.dateTimeStr = 'Oct 14, 2024',
    this.newBalance = 4300.00,
  });

  @override
  State<DepositSuccessScreen> createState() => _DepositSuccessScreenState();
}

class _DepositSuccessScreenState extends State<DepositSuccessScreen>
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
            // Top Subtle Green Ambient Glow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 260,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.vibrantGreen.withValues(alpha: 0.15),
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

                        // Animated Mark Icon / Logo Section (matching user request & screenshot)
                        Center(
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Animated Pulsing Halo Ring
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.vibrantGreen.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                                // Surrounding Burst Particles (Matching screenshot ✨)
                                ..._buildParticleBurst(),

                                // Spring Scaled Checkmark Icon Circle
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.vibrantGreen,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.vibrantGreen.withValues(alpha: 0.4),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: AppColors.darkGreen,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Headline (matching screenshot)
                        const Text(
                          'Deposit Successful!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Details Card (matching screenshot)
                        Container(
                          padding: const EdgeInsets.all(20),
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
                              _buildCardRow(
                                label: 'Amount',
                                valueWidget: Text(
                                  formatGhs(widget.amount, decimals: true),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF5F5F5)),
                              _buildCardRow(
                                label: 'Payment Method',
                                valueWidget: Row(
                                  children: [
                                    const Icon(Icons.phone_android_rounded, color: AppColors.forestGreen, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.sourceAccount,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF5F5F5)),
                              _buildCardRow(
                                label: 'Date',
                                value: widget.dateTimeStr,
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF5F5F5)),
                              _buildCardRow(
                                label: 'Transaction ID',
                                value: widget.transactionId,
                                valueColor: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Action Buttons Area (matching screenshot)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
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
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            AppState().setMonthlyIncome(widget.amount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Monthly income set to GHS ${widget.amount.toStringAsFixed(0)}',
                                ),
                              ),
                            );
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home', (route) => false);
                            AppState().openBudgetTab();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.darkGreen, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Set as this month’s income',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          showTransactionReceipt(
                            context,
                            title: 'Deposit Receipt',
                            amount: widget.amount,
                            counterpartLabel: 'Source',
                            counterpartValue: widget.sourceAccount,
                            transactionId: widget.transactionId,
                            dateTimeStr: widget.dateTimeStr,
                            newBalance: widget.newBalance,
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined,
                            color: AppColors.darkGreen, size: 18),
                        label: const Text(
                          'View Receipt',
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

  Widget _buildCardRow({
    required String label,
    String? value,
    Widget? valueWidget,
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
        valueWidget ??
            Text(
              value ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.darkGreen,
              ),
            ),
      ],
    );
  }
}
