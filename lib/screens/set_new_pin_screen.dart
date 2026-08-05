import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class SetNewPinScreen extends StatefulWidget {
  const SetNewPinScreen({super.key});

  @override
  State<SetNewPinScreen> createState() => _SetNewPinScreenState();
}

class _SetNewPinScreenState extends State<SetNewPinScreen> {
  final List<TextEditingController> _newPinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _newPinFocusNodes = List.generate(4, (_) => FocusNode());

  final List<TextEditingController> _confirmPinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _confirmPinFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _newPinControllers) {
      controller.dispose();
    }
    for (var node in _newPinFocusNodes) {
      node.dispose();
    }
    for (var controller in _confirmPinControllers) {
      controller.dispose();
    }
    for (var node in _confirmPinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _newPin => _newPinControllers.map((c) => c.text).join();
  String get _confirmPin => _confirmPinControllers.map((c) => c.text).join();

  void _handleSaveNewPin() {
    if (_newPin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 4-digit New PIN'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_confirmPin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm your 4-digit PIN'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_newPin != _confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    AppState().setPin(_newPin);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.vibrantGreen,
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.darkGreenAccent, size: 32),
        ),
        title: const Text(
          'PIN Reset Successful',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen),
        ),
        content: const Text(
          'Your new security PIN has been saved. Please sign in using your new PIN.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back to Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _onNewPinChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _newPinFocusNodes[index + 1].requestFocus();
      } else {
        _confirmPinFocusNodes[0].requestFocus();
      }
    }
  }

  void _onConfirmPinChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _confirmPinFocusNodes[index + 1].requestFocus();
      } else {
        _confirmPinFocusNodes[index].unfocus();
        _handleSaveNewPin();
      }
    }
  }

  Widget _buildPinBoxRow({
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
    required Function(int, String) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 56,
          height: 64,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  controllers[index].text.isEmpty &&
                  index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
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
              onChanged: (value) => onChanged(index, value),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
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
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Header Badge & Text
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.vibrantGreen,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 32,
                        color: AppColors.darkGreenAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set New PIN',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a new 4-digit PIN to secure your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Enter New PIN Group
              const Text(
                'Enter New PIN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildPinBoxRow(
                controllers: _newPinControllers,
                focusNodes: _newPinFocusNodes,
                onChanged: _onNewPinChanged,
              ),
              const SizedBox(height: 28),

              // Confirm New PIN Group
              const Text(
                'Confirm New PIN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildPinBoxRow(
                controllers: _confirmPinControllers,
                focusNodes: _confirmPinFocusNodes,
                onChanged: _onConfirmPinChanged,
              ),
              const SizedBox(height: 40),

              // Primary Action Button ("Save New PIN")
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSaveNewPin,
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
                        'Save New PIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreenAccent,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 20,
                        color: AppColors.darkGreenAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
