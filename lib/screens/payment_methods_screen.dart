import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedPrimaryIndex = 0; // MTN MoMo default primary

  final List<Map<String, String>> _momoAccounts = [
    {
      'provider': 'MTN Mobile Money',
      'number': '024 *** 4567',
      'code': 'MTN',
      'color': '0xFFFFCC00',
    },
    {
      'provider': 'Telecel Cash',
      'number': '050 *** 8819',
      'code': 'Telecel',
      'color': '0xFFE50012',
    },
  ];

  final List<Map<String, String>> _bankCards = [
    {
      'bank': 'Ecobank Visa Debit',
      'number': '•••• •••• •••• 4920',
      'expiry': '10/26',
    },
  ];

  void _showAddMoMoModal() {
    final phoneController = TextEditingController();
    String selectedNetwork = 'MTN Mobile Money';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Mobile Money',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedNetwork,
                decoration: InputDecoration(
                  labelText: 'Select Network Provider',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: const [
                  DropdownMenuItem(value: 'MTN Mobile Money', child: Text('MTN Mobile Money')),
                  DropdownMenuItem(value: 'Telecel Cash', child: Text('Telecel Cash')),
                  DropdownMenuItem(value: 'AT Money', child: Text('AT Money')),
                ],
                onChanged: (val) {
                  if (val != null) selectedNetwork = val;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'e.g. 024 123 4567',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (phoneController.text.trim().isNotEmpty) {
                      setState(() {
                        _momoAccounts.add({
                          'provider': selectedNetwork,
                          'number': phoneController.text.trim(),
                          'code': selectedNetwork.contains('MTN') ? 'MTN' : 'MoMo',
                          'color': selectedNetwork.contains('MTN') ? '0xFFFFCC00' : '0xFFE50012',
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mobile Money account added!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Link Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mobile Money Section (Figma 4:1077)
              const Text(
                'Mobile Money',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 14),

              ...List.generate(_momoAccounts.length, (index) {
                final item = _momoAccounts[index];
                final bool isPrimary = index == _selectedPrimaryIndex;
                final Color circleColor = Color(int.parse(item['color']!));

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPrimary
                          ? AppColors.vibrantGreen
                          : AppColors.notchColor.withValues(alpha: 0.3),
                      width: isPrimary ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Provider Circle Logo Badge (Figma 4:1083)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor,
                        ),
                        child: Center(
                          child: Text(
                            item['code']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: item['code'] == 'MTN' ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text Column (Figma 4:1085)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item['provider']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                if (isPrimary) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.vibrantGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Primary',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['number']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Options Popup Button (Figma 4:1095)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                        onSelected: (value) {
                          if (value == 'primary') {
                            setState(() {
                              _selectedPrimaryIndex = index;
                            });
                          } else if (value == 'delete') {
                            if (_momoAccounts.length > 1) {
                              setState(() {
                                _momoAccounts.removeAt(index);
                                if (_selectedPrimaryIndex >= _momoAccounts.length) {
                                  _selectedPrimaryIndex = 0;
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('At least one payment method is required.')),
                              );
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          if (!isPrimary)
                            const PopupMenuItem(
                              value: 'primary',
                              child: Text('Set as Primary'),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Remove Account', style: TextStyle(color: Color(0xFFD32F2F))),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              // Add New MoMo Button
              GestureDetector(
                onTap: _showAddMoMoModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.forestGreen.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: AppColors.forestGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Mobile Money Account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bank Cards & Accounts Section
              const Text(
                'Bank Cards & Accounts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 14),

              ...List.generate(_bankCards.length, (index) {
                final card = _bankCards[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkGreen.withValues(alpha: 0.1),
                        ),
                        child: const Center(
                          child: Icon(Icons.credit_card_rounded, color: AppColors.darkGreen, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['bank']!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${card['number']!} • Exp ${card['expiry']!}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              }),

              // Link Bank Card Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link bank card feature...')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.forestGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_card_rounded, color: AppColors.forestGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Link Bank Card or Account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
