import 'package:flutter/material.dart';
import 'screens/budget_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/home_screen.dart';
import 'screens/number_verification_screen.dart';
import 'screens/reset_pin_screen.dart';
import 'screens/set_new_pin_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'theme/app_theme.dart';

import 'screens/notification_screen.dart';
import 'screens/withdraw_screen.dart';
import 'screens/deposit_screen.dart';
import 'screens/set_new_goal_screen.dart';
import 'screens/goal_success_screen.dart';
import 'screens/goal_detail_screen.dart';
import 'screens/withdrawal_success_screen.dart';
import 'screens/deposit_success_screen.dart';
import 'screens/deposit_error_screen.dart';
import 'screens/withdrawal_error_screen.dart';

void main() {
  runApp(const KwanpaSusuApp());
}

class KwanpaSusuApp extends StatelessWidget {
  const KwanpaSusuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kwanpa Susu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/verify') {
          final phone = settings.arguments as String? ?? '+233 54 123 4567';
          return MaterialPageRoute(
            builder: (context) => NumberVerificationScreen(phoneNumber: phone),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const GetStartedScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
        '/reset_pin': (context) => const ResetPinScreen(),
        '/set_new_pin': (context) => const SetNewPinScreen(),
        '/home': (context) => const HomeScreen(),
        '/budget': (context) => const BudgetScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/withdraw': (context) => const WithdrawScreen(),
        '/deposit': (context) => const DepositScreen(),
        '/create_goal': (context) => const SetNewGoalScreen(),
        '/goal_success': (context) => const GoalSuccessScreen(),
        '/goal_detail': (context) => const GoalDetailScreen(),
        '/withdrawal_success': (context) => const WithdrawalSuccessScreen(),
        '/deposit_success': (context) => const DepositSuccessScreen(),
        '/deposit_error': (context) => const DepositErrorScreen(),
        '/withdrawal_error': (context) => const WithdrawalErrorScreen(),
      },
    );
  }
}
