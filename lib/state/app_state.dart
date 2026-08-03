import 'package:flutter/material.dart';

class SusuGoal {
  final String id;
  final String title;
  final double targetAmount;
  double currentSaved;
  final String frequency;
  final String lockDate;
  final String category;
  final IconData icon;
  final bool isAutoSave;
  final double autoSaveAmount;

  SusuGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentSaved,
    required this.frequency,
    required this.lockDate,
    this.category = 'Personal',
    this.icon = Icons.savings_rounded,
    this.isAutoSave = true,
    this.autoSaveAmount = 20.00,
  });

  double get progressPercentage => (currentSaved / targetAmount).clamp(0.0, 1.0);
  bool get isAchieved => currentSaved >= targetAmount;
}

class TransactionItem {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isDeposit; // true = deposit/income, false = withdraw/expense
  final IconData icon;
  final String status;
  final String method;

  TransactionItem({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isDeposit,
    required this.icon,
    this.status = 'Completed',
    this.method = 'MTN MoMo',
  });
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  double _totalBalance = 4300.00;
  double get totalBalance => _totalBalance;

  // Loading flags for UI shimmer placeholders
  bool isLoadingTransactions = true;
  bool isLoadingGoals = true;
  bool isLoadingPayments = true;

  // Simulate loading after a short delay (e.g., 1 second)
  void simulateLoading() async {
    await Future.delayed(const Duration(seconds: 1));
    isLoadingTransactions = false;
    isLoadingGoals = false;
    isLoadingPayments = false;
    notifyListeners();
  }

  final List<SusuGoal> _goals = [
    SusuGoal(
      id: 'g1',
      title: 'New Laptop',
      targetAmount: 5000.00,
      currentSaved: 3500.00,
      frequency: 'Weekly',
      lockDate: 'Dec 20, 2024',
      category: 'Tech',
      icon: Icons.laptop_mac_rounded,
      autoSaveAmount: 20.00,
    ),
    SusuGoal(
      id: 'g2',
      title: 'Emergency Fund',
      targetAmount: 10000.00,
      currentSaved: 6200.00,
      frequency: 'Monthly',
      lockDate: 'Jan 15, 2025',
      category: 'Safety',
      icon: Icons.shield_rounded,
      autoSaveAmount: 100.00,
    ),
    SusuGoal(
      id: 'g3',
      title: 'Dec Vacation',
      targetAmount: 3000.00,
      currentSaved: 1200.00,
      frequency: 'Weekly',
      lockDate: 'Dec 01, 2024',
      category: 'Travel',
      icon: Icons.flight_takeoff_rounded,
      autoSaveAmount: 50.00,
    ),
  ];

  List<SusuGoal> get goals => List.unmodifiable(_goals);

  final List<TransactionItem> _transactions = [
    TransactionItem(
      id: 'tx1',
      title: 'Deposit via MTN MoMo',
      date: 'Today, 2:15 PM',
      amount: 500.00,
      isDeposit: true,
      icon: Icons.south_west_rounded,
      method: 'MTN MoMo',
    ),
    TransactionItem(
      id: 'tx2',
      title: 'Auto-Save to New Laptop',
      date: 'Yesterday, 9:00 AM',
      amount: 50.00,
      isDeposit: false,
      icon: Icons.savings_rounded,
      method: 'Susu Wallet',
    ),
    TransactionItem(
      id: 'tx3',
      title: 'Withdrawal to Telecel Cash',
      date: 'Oct 12, 2024',
      amount: 200.00,
      isDeposit: false,
      icon: Icons.north_east_rounded,
      method: 'Telecel Cash',
    ),
    TransactionItem(
      id: 'tx4',
      title: 'Deposit via Visa Card',
      date: 'Oct 10, 2024',
      amount: 1200.00,
      isDeposit: true,
      icon: Icons.credit_card_rounded,
      method: 'Ecobank Visa',
    ),
  ];

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  void deposit(double amount, String method) {
    _totalBalance += amount;
    _transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Deposit via $method',
        date: 'Just now',
        amount: amount,
        isDeposit: true,
        icon: Icons.south_west_rounded,
        method: method,
      ),
    );
    notifyListeners();
  }

  void withdraw(double amount, String destination) {
    if (_totalBalance >= amount) {
      _totalBalance -= amount;
      _transactions.insert(
        0,
        TransactionItem(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Withdrawal to $destination',
          date: 'Just now',
          amount: amount,
          isDeposit: false,
          icon: Icons.north_east_rounded,
          method: destination,
        ),
      );
      notifyListeners();
    }
  }

  void addGoal({
    required String title,
    required double targetAmount,
    required String frequency,
    required String lockDate,
  }) {
    _goals.insert(
      0,
      SusuGoal(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        targetAmount: targetAmount,
        currentSaved: 0.00,
        frequency: frequency,
        lockDate: lockDate,
        icon: _selectIconForTitle(title),
      ),
    );
    notifyListeners();
  }

  void contributeToGoal(String goalId, double amount) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1 && _totalBalance >= amount) {
      _totalBalance -= amount;
      _goals[index].currentSaved += amount;
      _transactions.insert(
        0,
        TransactionItem(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Contributed to ${_goals[index].title}',
          date: 'Just now',
          amount: amount,
          isDeposit: false,
          icon: Icons.savings_rounded,
          method: 'Susu Wallet',
        ),
      );
      notifyListeners();
    }
  }

  IconData _selectIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('car') || lower.contains('vehicle')) return Icons.directions_car_rounded;
    if (lower.contains('house') || lower.contains('rent') || lower.contains('home')) return Icons.home_rounded;
    if (lower.contains('phone') || lower.contains('tech') || lower.contains('laptop')) return Icons.devices_rounded;
    if (lower.contains('school') || lower.contains('fee') || lower.contains('education')) return Icons.school_rounded;
    if (lower.contains('trip') || lower.contains('vacation') || lower.contains('travel')) return Icons.flight_takeoff_rounded;
    return Icons.savings_rounded;
  }
}
