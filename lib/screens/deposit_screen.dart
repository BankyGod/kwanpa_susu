import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'deposit_success_screen.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController(text: '100.00');
  String _selectedMethod = 'MTN MoMo';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'mtn',
      'name': 'MTN MoMo',
      'number': '024 *** ****',
      'fullNumber': 'MTN (024 *** 4587)',
      'icon': Icons.smartphone_rounded,
    },
    {
      'id': 'telecel',
      'name': 'Telecel Cash',
      'number': 'Add new number',
      'fullNumber': 'Telecel Cash',
      'icon': Icons.smartphone_outlined,
    },
    {
      'id': 'bank',
      'name': 'Bank Account',
      'number': 'Link your bank',
      'fullNumber': 'Bank Account',
      'icon': Icons.account_balance_outlined,
    },
  ];

  void _addQuickAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  void _processDeposit() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a deposit amount')),
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

    // Push DepositSuccessScreen matching Figma 4:1761
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DepositSuccessScreen(
          amount: amount,
          sourceAccount: '$_selectedMethod (024 *** 4587)',
          transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          dateTimeStr: 'Today, ${TimeOfDay.now().format(context)}',
          newBalance: 4200.00 + amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethodObj = _paymentMethods.firstWhere(
      (element) => element['name'] == _selectedMethod,
      orElse: () => _paymentMethods.first,
    );

    final currentAmount = double.tryParse(_amountController.text) ?? 100.00;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 22),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text(
          'Deposit Funds',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enter Amount Section (matching screenshot)
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'ENTER AMOUNT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Display / Input Row with Underline
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text(
                                  'GHS ',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) => setState(() {}),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGreen,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick Add Amount Chips (+ 50, + 100, + 500)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildQuickPill('+ 50', 50.0),
                              const SizedBox(width: 12),
                              _buildQuickPill('+ 100', 100.0),
                              const SizedBox(width: 12),
                              _buildQuickPill('+ 500', 500.0),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pay From Header & Cards
                    const Text(
                      'Pay From',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),

                    const SizedBox(height: 24),

                    // Transaction Summary Card (matching screenshot)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textSecondary),
                              SizedBox(width: 6),
                              Text(
                                'TRANSACTION SUMMARY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _buildSummaryRow('Source Account', selectedMethodObj['fullNumber']!),
                          const SizedBox(height: 10),
                          _buildSummaryRow('Deposit Amount', 'GHS ${currentAmount.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          _buildSummaryRow('Network Fee', 'Free', valueColor: AppColors.forestGreen),

                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total to Pay',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              Text(
                                'GHS ${currentAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Primary Action Button (matching screenshot)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _processDeposit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGreen,
                    elevation: 3,
                    shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, color: AppColors.darkGreenAccent, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String label, double value) {
    final isSelected = (double.tryParse(_amountController.text) ?? 0.0) == value;

    return GestureDetector(
      onTap: () => _addQuickAmount(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardGradientEnd : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.cardGradientEnd : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.darkGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.darkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final bool isSelected = _selectedMethod == method['name'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method['name']!;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDF2F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.notchColor.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkGreen : const Color(0xFFF4F6F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                method['icon'] as IconData,
                color: isSelected ? AppColors.vibrantGreen : AppColors.darkGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['number'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.darkGreen : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
