import 'package:flutter/material.dart';
import 'screens/get_started_screen.dart';
import 'screens/number_verification_screen.dart';
import 'screens/reset_pin_screen.dart';
import 'screens/set_new_pin_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'theme/app_theme.dart';

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
      },
    );
  }
}
