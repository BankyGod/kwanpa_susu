import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoalSuccessScreen extends StatelessWidget {
  final String goalTitle;
  final double targetAmount;
  final String targetDate;
  final String frequency;
  final double contributionAmount;

  const GoalSuccessScreen({
    super.key,
    this.goalTitle = 'New Laptop',
    this.targetAmount = 5000.00,
    this.targetDate = 'Dec 20, 2024',
    this.frequency = 'week',
    this.contributionAmount = 20.00,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Top Light Green Background Glow
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

            // Main Content Canvas (matching screenshot)
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Centered Hero Badge with Padlock & Leaf Badge (matching screenshot)
                        Center(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer Ring Halo
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.vibrantGreen.withValues(alpha: 0.25),
                                  ),
                                ),
                                // Inner Vibrant Green Circle
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.vibrantGreen,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: AppColors.darkGreen,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                // Floating Leaf Badge (matching screenshot)
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.eco_rounded,
                                        color: AppColors.darkGreenAccent,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Headline & Subtitle Message (matching screenshot)
                        const Text(
                          'Goal Set & Locked!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "You're officially on your way to\nsaving for '$goalTitle'.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
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
                              _buildDetailRow(
                                icon: Icons.radar_rounded,
                                label: 'Target',
                                value: 'GHS ${targetAmount.toStringAsFixed(2)}',
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF5F5F5)),
                              _buildDetailRow(
                                icon: Icons.calendar_today_outlined,
                                label: 'Unlock Date',
                                value: targetDate,
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF5F5F5)),
                              _buildDetailRow(
                                icon: Icons.autorenew_rounded,
                                label: 'Auto-save',
                                valueWidget: Text.rich(
                                  TextSpan(
                                    text: 'GHS ${contributionAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGreen,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' / ${frequency.toLowerCase()}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Primary & Secondary Buttons Area (matching screenshot)
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
                            'Go to Savings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home', (route) => false);
                        },
                        child: const Text(
                          'Home',
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18),
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
        valueWidget ??
            Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
      ],
    );
  }
}
