import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GoalAchievedScreen extends StatefulWidget {
  final String goalTitle;
  final double targetAmount;
  final String achievedDate;

  const GoalAchievedScreen({
    super.key,
    this.goalTitle = 'New Laptop',
    this.targetAmount = 5000.00,
    this.achievedDate = 'Dec 20, 2024',
  });

  @override
  State<GoalAchievedScreen> createState() => _GoalAchievedScreenState();
}

class _GoalAchievedScreenState extends State<GoalAchievedScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 1. Hero Badge Spring Bounce Animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // 2. Continuous Glow Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Falling Confetti Animation Loop
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Generate random confetti particles (matching Figma 4:1910)
    for (int i = 0; i < 40; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 8 + 6,
          speed: _random.nextDouble() * 0.4 + 0.3,
          color: _randomColor(),
          isCircle: _random.nextBool(),
          angle: _random.nextDouble() * pi * 2,
        ),
      );
    }

    _scaleController.forward();
  }

  Color _randomColor() {
    final colors = [
      const Color(0xFFFFE066), // Gold Yellow
      AppColors.vibrantGreen,  // Vibrant Lime
      const Color(0xFF4CAF50), // Forest Green
      Colors.white,            // Sparkle White
      const Color(0xFF81C784), // Light Green
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen, // Figma 4:1909 dark background
      body: SafeArea(
        child: Stack(
          children: [
            // Animated Falling Confetti Background Painter (Figma 4:1910)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

            // Top Subtle Green Ambient Glow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 350,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [
                      AppColors.vibrantGreen.withValues(alpha: 0.25),
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
                        const SizedBox(height: 52),

                        // Animated Trophy Hero Badge Section
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing Outer Ring Glow
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.vibrantGreen.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                                // Inner Ring Glow
                                Container(
                                  width: 106,
                                  height: 106,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.vibrantGreen.withValues(alpha: 0.15),
                                  ),
                                ),

                                // Spring Scale Icon Circle Badge
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.emoji_events_rounded,
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

                        // Celebration Title & Message
                        const Text(
                          'Goal Achieved!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Congratulations! You have successfully saved for "${widget.goalTitle}". Your target has been reached!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Summary Card (Glassmorphic look on dark background)
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003828),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.vibrantGreen.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                label: 'Total Saved',
                                value: 'GH₵ ${widget.targetAmount.toStringAsFixed(2)}',
                                valueColor: AppColors.vibrantGreen,
                                isBold: true,
                              ),
                              const Divider(height: 24, color: Color(0xFF004D38)),
                              _buildSummaryRow(
                                label: 'Target Date Achieved',
                                value: widget.achievedDate,
                                valueColor: Colors.white,
                              ),
                              const Divider(height: 24, color: Color(0xFF004D38)),
                              _buildSummaryRow(
                                label: 'Susu Reward Earned',
                                value: '+ GH₵ 50.00 Bonus',
                                valueColor: const Color(0xFFFFD700),
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

                // Actions Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/withdraw');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.vibrantGreen,
                            elevation: 4,
                            shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, color: AppColors.darkGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Withdraw to Mobile Money',
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
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home', (route) => false);
                        },
                        child: Text(
                          'Back to Dashboard',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// Confetti Helper Classes
class _ConfettiParticle {
  double x;
  double y;
  double size;
  double speed;
  Color color;
  bool isCircle;
  double angle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.isCircle,
    required this.angle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final double yPos = ((particle.y + progress * particle.speed) % 1.0) * size.height;
      final double xPos = (particle.x + sin(progress * pi * 2 + particle.angle) * 0.04) * size.width;

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      if (particle.isCircle) {
        canvas.drawCircle(Offset(xPos, yPos), particle.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(xPos, yPos);
        canvas.rotate(particle.angle + progress * pi * 2);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 1.6), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
