import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'goal_success_screen.dart';

class SetNewGoalScreen extends StatefulWidget {
  const SetNewGoalScreen({super.key});

  @override
  State<SetNewGoalScreen> createState() => _SetNewGoalScreenState();
}

class _SetNewGoalScreenState extends State<SetNewGoalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();

  bool _autoContributions = true;
  String _selectedFrequency = 'Daily';

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _targetDateController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _createGoal() {
    final title = _titleController.text.trim();
    final targetText = _targetAmountController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    if (targetText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a target amount')),
      );
      return;
    }

    final double? targetAmount = double.tryParse(targetText);
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount')),
      );
      return;
    }

    // Navigate to GoalSuccessScreen matching Figma 4:1847
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GoalSuccessScreen(
          goalTitle: title,
          targetAmount: targetAmount,
          targetDate: _targetDateController.text.isNotEmpty ? _targetDateController.text : '12/31/2026',
          frequency: _selectedFrequency,
          contributionAmount: 25.00,
        ),
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
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'New Goal',
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header (matching screenshot)
              const Text(
                'Set Your Goal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Define what you're saving for and let's make it happen.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Card 1: Form Inputs (matching screenshot)
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Goal Title
                    const Text(
                      'Goal Title',
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.5)),
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 15, color: AppColors.darkGreen, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'e.g., New Laptop, Trotro Fare',
                          hintStyle: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Field 2: Target Amount (GHS)
                    const Text(
                      'Target Amount (GHS)',
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.5)),
                      ),
                      child: TextField(
                        controller: _targetAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 16, color: AppColors.darkGreen, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 16, right: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '₵',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(fontSize: 16, color: Color(0xFFB0BEC5)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Field 3: Target Date (Time-lock)
                    const Text(
                      'Target Date (Time-lock)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.notchColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _targetDateController.text.isNotEmpty ? _targetDateController.text : 'mm/dd/yyyy',
                              style: TextStyle(
                                fontSize: 14,
                                color: _targetDateController.text.isNotEmpty ? AppColors.darkGreen : const Color(0xFFB0BEC5),
                                fontWeight: _targetDateController.text.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Automatic Contributions (matching screenshot)
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automatic Contributions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Build your savings on autopilot.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _autoContributions,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF2979FF),
                          onChanged: (val) => setState(() => _autoContributions = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daily / Weekly / Monthly Pills
                    Row(
                      children: _frequencies.map((freq) {
                        final isSelected = _selectedFrequency == freq;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFrequency = freq),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.vibrantGreen.withValues(alpha: 0.15) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.vibrantGreen : const Color(0xFFE0E0E0),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  freq,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppColors.darkGreenAccent : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Projection Summary Hero Card (matching screenshot)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B3D2E),
                      AppColors.darkGreen,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Projection Summary',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA3B3A9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₵25.00',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '/ day',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFA3B3A9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.trending_up_rounded, color: AppColors.vibrantGreen, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Reaches target by selected date.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA3B3A9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Lock & Save Action Button & Disclaimer
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _createGoal,
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
                        'Lock & Save',
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
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Funds will be locked securely until your target date.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
