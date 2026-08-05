import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import 'withdrawal_success_screen.dart';
import '../widgets/bounce_button.dart';
import '../widgets/kyc_gate.dart';
import '../services/biometric_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;
  String? _selectedMethodId;

  @override
  void initState() {
    super.initState();
    final cats = AppState().budgetCategories;
    _selectedCategory =
        cats.isNotEmpty ? cats.first.name : 'Food & Groceries';
    final primary = AppState().primaryPaymentMethod;
    final methods = AppState().paymentMethods;
    _selectedMethodId =
        primary?.id ?? (methods.isNotEmpty ? methods.first.id : null);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  PaymentMethod? get _selectedMethod {
    final methods = AppState().paymentMethods;
    if (methods.isEmpty) return null;
    final id = _selectedMethodId;
    if (id != null) {
      for (final m in methods) {
        if (m.id == id) return m;
      }
    }
    final primary = AppState().primaryPaymentMethod;
    _selectedMethodId = primary?.id ?? methods.first.id;
    return primary ?? methods.first;
  }

  Future<bool> _confirmTwoFactorIfNeeded() async {
    if (!AppState().twoFactorEnabled) return true;

    // Prefer biometrics when enabled on this device.
    if (AppState().biometricEnabled) {
      final available = await BiometricService.instance.isAvailable;
      if (available) {
        final label = await BiometricService.instance.biometricLabel;
        final bioOk = await BiometricService.instance.authenticate(
          reason: 'Confirm withdrawal with $label',
        );
        if (bioOk) return true;
        if (!mounted) return false;
        // Fall through to PIN if biometric cancelled/failed.
      }
    }

    if (!mounted) return false;
    final pinController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm with PIN'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'Enter your PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length != 4) return;
              if (AppState().verifyPin(pin)) {
                Navigator.pop(ctx, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _processWithdrawal() async {
    final allowed = await ensureKycVerified(
      context,
      actionLabel: 'withdraw',
    );
    if (!allowed || !mounted) return;

    final amountText = _amountController.text.trim();
    final available = AppState().totalBalance;

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a withdrawal amount')),
      );
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (amount > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount exceeds available balance')),
      );
      return;
    }

    final method = _selectedMethod;
    if (method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a payment method first')),
      );
      return;
    }

    final category = _selectedCategory ?? 'Food & Groceries';
    final warning = AppState().budgetImpactWarning(category, amount);
    if (warning != null) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            AppState().budgetCategoryByName(category)?.isProtected == true
                ? 'Protected category'
                : 'Budget warning',
          ),
          content: Text(warning),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Withdraw anyway',
                  style: TextStyle(color: Color(0xFFD32F2F))),
            ),
          ],
        ),
      );
      if (go != true || !mounted) return;
    }

    if (!await _confirmTwoFactorIfNeeded() || !mounted) return;

    final dest = '${method.name} (${method.maskedNumber})';
    final ok = AppState().withdraw(
      amount,
      dest,
      category: category,
    );
    if (!ok) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/withdrawal_error',
        arguments: {
          'amount': amount,
          'destination': dest,
          'message': AppState().lastError ?? 'Withdrawal could not be completed.',
        },
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WithdrawalSuccessScreen(
          amount: amount,
          destinationAccount: dest,
          transactionId:
              'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          dateTimeStr: 'Today, ${TimeOfDay.now().format(context)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methods = AppState().paymentMethods;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.darkGreen, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Withdraw Funds',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppColors.notchColor.withValues(alpha: 0.3)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.vibrantGreen.withValues(alpha: 0.05),
                            Colors.white,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.darkGreen.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'AVAILABLE BALANCE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                'GHS ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              Text(
                                AppState().totalBalance.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Withdrawal Amount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                AppColors.notchColor.withValues(alpha: 0.5)),
                      ),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 16, right: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'GHS',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB0BEC5),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Budget Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                AppColors.notchColor.withValues(alpha: 0.5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: AppState()
                              .budgetCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.name,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Send To',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (methods.isEmpty)
                      TextButton.icon(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/payment_methods'),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add a payment method'),
                      )
                    else
                      ...methods.map((m) {
                        final selected = _selectedMethodId == m.id;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedMethodId = m.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEDF2F0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppColors.darkGreen
                                    : AppColors.notchColor
                                        .withValues(alpha: 0.5),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  m.type == 'bank'
                                      ? Icons.account_balance_outlined
                                      : Icons.smartphone_rounded,
                                  color: AppColors.darkGreen,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                      Text(
                                        m.maskedNumber,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: selected
                                      ? AppColors.darkGreen
                                      : AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: BounceButton(
                  onPressed: _processWithdrawal,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantGreen,
                      disabledBackgroundColor: AppColors.vibrantGreen,
                      elevation: 3,
                      shadowColor:
                          AppColors.vibrantGreen.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm Withdrawal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreenAccent,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: AppColors.darkGreenAccent, size: 20),
                      ],
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
}
