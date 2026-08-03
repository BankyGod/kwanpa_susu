import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoalDetailScreen extends StatelessWidget {
  final String title;
  final double currentAmount;
  final double targetAmount;
  final String category;
  final String unlockDate;
  final String frequency;
  final double contributionAmount;
  final bool isLocked;

  const GoalDetailScreen({
    super.key,
    this.title = 'New House Deposit',
    this.currentAmount = 45000.00,
    this.targetAmount = 100000.00,
    this.category = 'Real Estate',
    this.unlockDate = 'Aug 15, 2026',
    this.frequency = 'Weekly',
    this.contributionAmount = 500.00,
    this.isLocked = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentAmount / targetAmount).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Goal Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section (Hero Card)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.darkGreen,
                            AppColors.cardGradientEnd,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkGreen.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB74D).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFFB74D)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_rounded, size: 12, color: Color(0xFFFFB74D)),
                                    const SizedBox(width: 4),
                                    Text(
                                      isLocked ? 'Time-Locked' : 'Unlocked',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFB74D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'GH₵ ${currentAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.vibrantGreen,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '/ GH₵ ${targetAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFA3B3A9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Linear Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vibrantGreen),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$percentage% Completed',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.vibrantGreen,
                                ),
                              ),
                              Text(
                                'Target: $unlockDate',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFA3B3A9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section - Bento Grid: Status & Countdown (matching Figma 4:1484)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.hourglass_top_rounded, color: Color(0xFFD84315), size: 18),
                                    SizedBox(width: 6),
                                    Text('Time Lock', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '142 Days',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Until Payout',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.autorenew_rounded, color: AppColors.forestGreen, size: 18),
                                    SizedBox(width: 6),
                                    Text('Auto-Save', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'GH₵ ${contributionAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Per ${frequency.toLowerCase()}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Automatic Savings Setting Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.bolt_rounded, color: AppColors.forestGreen, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Auto-Deposit Enabled',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: true,
                                activeThumbColor: AppColors.vibrantGreen,
                                activeTrackColor: AppColors.darkGreenAccent,
                                onChanged: (val) {},
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFFF5F5F5)),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Source Account', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              Text('MTN MoMo (024 *** 4587)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contribution Activity History
                    const Text(
                      'Recent Contributions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildHistoryTile('Weekly Auto-Deposit', 'Aug 1, 2026', '+ GH₵ 500.00'),
                    _buildHistoryTile('Weekly Auto-Deposit', 'Jul 25, 2026', '+ GH₵ 500.00'),
                    _buildHistoryTile('Manual Deposit', 'Jul 20, 2026', '+ GH₵ 2,000.00'),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/deposit'),
                  icon: const Icon(Icons.add_rounded, color: AppColors.darkGreenAccent),
                  label: const Text(
                    'Add Funds to Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreenAccent,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGreen,
                    elevation: 3,
                    shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String title, String date, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_downward_rounded, color: AppColors.forestGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
          ),
        ],
      ),
    );
  }
}
