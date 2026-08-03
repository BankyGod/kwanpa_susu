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
import 'utils/page_transitions.dart';

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
import 'screens/personal_info_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/security_screen.dart';
import 'screens/goal_achieved_screen.dart';

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
        Widget page;
        switch (settings.name) {
          case '/':
            page = const GetStartedScreen();
            break;
          case '/signup':
            page = const SignUpScreen();
            break;
          case '/signin':
            page = const SignInScreen();
            break;
          case '/reset_pin':
            page = const ResetPinScreen();
            break;
          case '/set_new_pin':
            page = const SetNewPinScreen();
            break;
          case '/verify':
            final phone = settings.arguments as String? ?? '+233 54 123 4567';
            page = NumberVerificationScreen(phoneNumber: phone);
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/budget':
            page = const BudgetScreen();
            break;
          case '/notifications':
            page = const NotificationScreen();
            break;
          case '/withdraw':
            page = const WithdrawScreen();
            break;
          case '/deposit':
            page = const DepositScreen();
            break;
          case '/create_goal':
            page = const SetNewGoalScreen();
            break;
          case '/goal_success':
            page = const GoalSuccessScreen();
            break;
          case '/goal_detail':
            page = const GoalDetailScreen();
            break;
          case '/withdrawal_success':
            page = const WithdrawalSuccessScreen();
            break;
          case '/deposit_success':
            page = const DepositSuccessScreen();
            break;
          case '/deposit_error':
            page = const DepositErrorScreen();
            break;
          case '/withdrawal_error':
            page = const WithdrawalErrorScreen();
            break;
          case '/personal_info':
            page = const PersonalInfoScreen();
            break;
          case '/payment_methods':
            page = const PaymentMethodsScreen();
            break;
          case '/security':
            page = const SecurityScreen();
            break;
          case '/goal_achieved':
            page = const GoalAchievedScreen();
            break;
          default:
            page = const GetStartedScreen();
        }

        return SmoothPageRoute(page: page, settings: settings);
      },
    );
  }
}
