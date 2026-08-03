import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final double _totalIncome = 4500.00;
  final double _totalExpenses = 2850.00;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Susu & Savings',
      'spent': 1000.0,
      'total': 1000.0,
      'icon': Icons.savings_rounded,
      'color': AppColors.forestGreen,
    },
    {
      'name': 'Food & Groceries',
      'spent': 850.0,
      'total': 1200.0,
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFE65100),
    },
    {
      'name': 'Utilities & Bills',
      'spent': 600.0,
      'total': 700.0,
      'icon': Icons.receipt_long_rounded,
      'color': const Color(0xFF0066CC),
    },
    {
      'name': 'Transport & Fuel',
      'spent': 400.0,
      'total': 600.0,
      'icon': Icons.directions_car_rounded,
      'color': const Color(0xFF7B1FA2),
    },
  ];

  double get _spentPercentage => (_totalExpenses / _totalIncome).clamp(0.0, 1.0);
  double get _remainingBudget => _totalIncome - _totalExpenses;

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_chart_rounded, color: AppColors.forestGreen),
            SizedBox(width: 10),
            Text('Add Budget Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkGreen)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Entertainment',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Budget Amount (GH₵)',
                hintText: 'e.g., 500',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                final double amount = double.tryParse(amountController.text) ?? 0.0;
                setState(() {
                  _categories.add({
                    'name': nameController.text,
                    'spent': 0.0,
                    'total': amount,
                    'icon': Icons.category_rounded,
                    'color': AppColors.darkGreenAccent,
                  });
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Category', style: TextStyle(color: AppColors.darkGreenAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkGreen, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.darkGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header Title & Subtitle
              const Text(
                'Budgeting',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your spending and stay on course.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Section - Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.darkGreen.withValues(alpha: 0.06),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Summary Header & "On Track" Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBCEDD7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'On Track',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Income & Expenses Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Income',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'GH₵ ${_totalIncome.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: AppColors.notchColor.withValues(alpha: 0.5),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'GH₵ ${_totalExpenses.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Visual Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(_spentPercentage * 100).toInt()}% Spent',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'GH₵ ${_remainingBudget.toStringAsFixed(0)} left',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _spentPercentage,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFEDEEF0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Category Breakdown Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add_rounded, color: AppColors.forestGreen, size: 18),
                    label: const Text(
                      'Add Budget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category Cards List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final double spent = cat['spent'];
                  final double total = cat['total'];
                  final double progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.notchColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (cat['color'] as Color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                color: cat['color'] as Color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat['name'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'GH₵ ${spent.toStringAsFixed(0)} of GH₵ ${total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: progress >= 1.0 ? Colors.redAccent : AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFEDEEF0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1.0 ? Colors.redAccent : (cat['color'] as Color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
