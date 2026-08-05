import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  final List<TextEditingController> _pinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  final String _selectedCountryCode = '+233';

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _pinCode => _pinControllers.map((c) => c.text).join();

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      if (_pinCode.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your 4-digit PIN'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!AppState().verifyPin(_pinCode)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect PIN. Try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      AppState().signIn();
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void _onPinDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _pinFocusNodes[index + 1].requestFocus();
      } else {
        _pinFocusNodes[index].unfocus();
        _handleSignIn();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Kwanpa Susu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkGreen, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header Section
                Center(
                  child: Column(
                    children: const [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Phone Number Input Group
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Country Code Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          border: Border.all(color: AppColors.notchColor, width: 1),
                        ),
                        child: Text(
                          '🇬🇭 $_selectedCountryCode',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191C1D),
                          ),
                        ),
                      ),

                      // Input Field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(fontSize: 15, color: Color(0xFF191C1D)),
                          decoration: const InputDecoration(
                            hintText: '024 123 4567',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter phone number';
                            }
                            if (value.trim().length < 8) {
                              return 'Enter valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // PIN Input Section Header (Label + Link)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PIN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/reset_pin');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4 Individual PIN Digit Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 68,
                      height: 64,
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.backspace &&
                              _pinControllers[index].text.isEmpty &&
                              index > 0) {
                            _pinFocusNodes[index - 1].requestFocus();
                          }
                        },
                        child: TextField(
                          controller: _pinControllers[index],
                          focusNode: _pinFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          obscureText: true,
                          obscuringCharacter: '•',
                          maxLength: 1,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.notchColor, width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.vibrantGreen, width: 2),
                            ),
                          ),
                          onChanged: (value) => _onPinDigitChanged(index, value),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),

                // Primary Action Button ("Sign In")
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSignIn,
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
                          'Sign In',
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
                const SizedBox(height: 24),

                // Registration Footer Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
