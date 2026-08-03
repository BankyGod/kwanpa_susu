import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Hero Graphic Area
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Background Image with ScaleMode CROP
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/susu_hero_bg.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.darkGreen, AppColors.cardGradientEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Atmospheric Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                          colors: [
                            AppColors.background.withValues(alpha: 0.2),
                            AppColors.background.withValues(alpha: 0.6),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Blur Glow Effect behind logo area
                  Center(
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.vibrantGreen.withValues(alpha: 0.18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vibrantGreen.withValues(alpha: 0.25),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Content Sheet
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00261B).withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Draggable Notch Indicator
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.notchColor.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Brand Identity - Logo Container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
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
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        size: 40,
                        color: AppColors.vibrantGreen,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Kwanpa Susu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tagline
                    const Text(
                      'Save Daily, Grow Together',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle / Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Manage your daily susu deposits, track savings goals, and secure your financial future effortlessly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
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
                              'Get Started',
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
                    const SizedBox(height: 14),

                    // Secondary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signin');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
