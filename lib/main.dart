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
import 'state/app_state.dart';

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
import 'screens/transaction_history_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/group_detail_screen.dart';
import 'screens/verify_ghana_card_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState().init();
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
      initialRoute: AppState().isAuthenticated ? '/home' : '/',
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
            String phone = '+233 54 123 4567';
            String purpose = 'signup';
            final args = settings.arguments;
            if (args is Map) {
              phone = args['phone'] as String? ?? phone;
              purpose = args['purpose'] as String? ?? purpose;
            } else if (args is String) {
              phone = args;
            }
            page = NumberVerificationScreen(
              phoneNumber: phone,
              purpose: purpose,
            );
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/goal_achieved':
            final args = settings.arguments;
            if (args is Map) {
              page = GoalAchievedScreen(
                goalTitle: args['title'] as String? ?? 'Savings Goal',
                targetAmount:
                    (args['amount'] as num?)?.toDouble() ?? 0,
                achievedDate: args['date'] as String? ?? 'Today',
              );
            } else {
              page = const GoalAchievedScreen();
            }
            break;
          case '/deposit_error':
            final args = settings.arguments;
            if (args is Map) {
              page = DepositErrorScreen(
                amount: (args['amount'] as num?)?.toDouble() ?? 0,
                sourceAccount:
                    args['source'] as String? ?? 'Mobile Money',
                errorMessage: args['message'] as String? ??
                    'Deposit could not be completed.',
              );
            } else {
              page = const DepositErrorScreen();
            }
            break;
          case '/withdrawal_error':
            final args = settings.arguments;
            if (args is Map) {
              page = WithdrawalErrorScreen(
                amount: (args['amount'] as num?)?.toDouble() ?? 0,
                destinationAccount:
                    args['destination'] as String? ?? 'Mobile Money',
                errorMessage: args['message'] as String? ??
                    'Withdrawal could not be completed.',
              );
            } else {
              page = const WithdrawalErrorScreen();
            }
            break;
          case '/budget':
            // Deep links open Home on the Budget tab.
            page = const HomeScreen();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppState().openBudgetTab();
            });
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
            final goalId = settings.arguments as String?;
            page = GoalDetailScreen(goalId: goalId);
            break;
          case '/withdrawal_success':
            page = const WithdrawalSuccessScreen();
            break;
          case '/deposit_success':
            page = const DepositSuccessScreen();
            break;
          case '/personal_info':
            page = const PersonalInfoScreen();
            break;
          case '/verify_ghana_card':
            page = const VerifyGhanaCardScreen();
            break;
          case '/payment_methods':
            page = const PaymentMethodsScreen();
            break;
          case '/security':
            page = const SecurityScreen();
            break;
          case '/transactions':
            page = const TransactionHistoryScreen();
            break;
          case '/groups':
            page = const GroupsScreen();
            break;
          case '/group_detail':
            final groupId = settings.arguments as String?;
            page = GroupDetailScreen(groupId: groupId);
            break;
          default:
            page = const GetStartedScreen();
        }

        return SmoothPageRoute(page: page, settings: settings);
      },
    );
  }
}
