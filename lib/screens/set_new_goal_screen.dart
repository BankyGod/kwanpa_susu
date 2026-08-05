import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
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
  String? _lockType; // flexible | strict — required

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

  double get _projectedContribution {
    final target = double.tryParse(_targetAmountController.text.trim()) ?? 0;
    if (target <= 0) return 0;

    int days = 30;
    final dateText = _targetDateController.text.trim();
    if (dateText.isNotEmpty) {
      final parts = dateText.split('/');
      if (parts.length == 3) {
        final month = int.tryParse(parts[0]);
        final day = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (month != null && day != null && year != null) {
          final targetDate = DateTime(year, month, day);
          final diff = targetDate.difference(DateTime.now()).inDays;
          if (diff > 0) days = diff;
        }
      }
    }

    switch (_selectedFrequency) {
      case 'Weekly':
        final weeks = (days / 7).ceil().clamp(1, 9999);
        return target / weeks;
      case 'Monthly':
        final months = (days / 30).ceil().clamp(1, 9999);
        return target / months;
      default:
        return target / days;
    }
  }

  String get _projectionUnit {
    switch (_selectedFrequency) {
      case 'Weekly':
        return '/ week';
      case 'Monthly':
        return '/ month';
      default:
        return '/ day';
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

    if (_lockType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Choose Flexible or Strict savings lock')),
      );
      return;
    }

    if (_lockType == 'strict' && _targetDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Strict goals need a target unlock date')),
      );
      return;
    }

    final String dateStr = _targetDateController.text.isNotEmpty
        ? _targetDateController.text
        : (_lockType == 'flexible' ? 'Flexible' : '12/31/2026');

    final contribution = _projectedContribution > 0
        ? double.parse(_projectedContribution.toStringAsFixed(2))
        : 25.00;

    AppState().addGoal(
      title: title,
      targetAmount: targetAmount,
      frequency: _selectedFrequency,
      lockDate: dateStr,
      isAutoSave: _autoContributions,
      autoSaveAmount: contribution,
      lockType: _lockType!,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GoalSuccessScreen(
          goalTitle: title,
          targetAmount: targetAmount,
          targetDate: dateStr,
          frequency: _selectedFrequency,
          contributionAmount: contribution,
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
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 16, color: AppColors.darkGreen, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 16, right: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'GHS',
                                  style: TextStyle(
                                    fontSize: 14,
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
                    Text(
                      _lockType == 'strict'
                          ? 'Unlock Date (required for Strict)'
                          : 'Target Date (optional)',
                      style: const TextStyle(
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

              // Lock type: Flexible vs Strict
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.notchColor.withValues(alpha: 0.3)),
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
                    const Text(
                      'Savings Lock Type',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose how withdrawals work for this goal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _lockTypeOption(
                      type: 'flexible',
                      title: 'Flexible',
                      subtitle:
                          'Withdraw anytime. No penalty — best for emergency funds.',
                      icon: Icons.lock_open_rounded,
                    ),
                    const SizedBox(height: 10),
                    _lockTypeOption(
                      type: 'strict',
                      title: 'Strict (Locked)',
                      subtitle:
                          'Still your money. Early withdraw before unlock date costs a 15% fee to Kwanpa.',
                      icon: Icons.lock_rounded,
                    ),
                    if (_lockType == null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Selection required',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'GHS ${_projectedContribution.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _projectionUnit,
                          style: const TextStyle(
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
              Center(
                child: Text(
                  _lockType == 'flexible'
                      ? 'Flexible goals: withdraw anytime with no fee.'
                      : _lockType == 'strict'
                          ? 'Strict goals: early withdraw before unlock costs 15%.'
                          : 'Choose Flexible or Strict before locking funds.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

  Widget _lockTypeOption({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _lockType == type;
    return InkWell(
      onTap: () => setState(() => _lockType = type),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.vibrantGreen.withValues(alpha: 0.12)
              : const Color(0xFFF7F9F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.vibrantGreen
                : AppColors.notchColor.withValues(alpha: 0.5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.darkGreen : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? AppColors.darkGreen : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
