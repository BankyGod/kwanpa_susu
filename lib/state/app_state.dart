import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final bool isLocked;

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
    this.isLocked = false,
  });

  double get progressPercentage =>
      (currentSaved / targetAmount).clamp(0.0, 1.0);
  bool get isAchieved => currentSaved >= targetAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'currentSaved': currentSaved,
        'frequency': frequency,
        'lockDate': lockDate,
        'category': category,
        'iconCode': icon.codePoint,
        'isAutoSave': isAutoSave,
        'autoSaveAmount': autoSaveAmount,
        'isLocked': isLocked,
      };

  factory SusuGoal.fromJson(Map<String, dynamic> json) => SusuGoal(
        id: json['id'] as String,
        title: json['title'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentSaved: (json['currentSaved'] as num).toDouble(),
        frequency: json['frequency'] as String,
        lockDate: json['lockDate'] as String,
        category: json['category'] as String? ?? 'Personal',
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          json['iconCode'] as int? ?? 0xe53e,
          fontFamily: 'MaterialIcons',
        ),
        isAutoSave: json['isAutoSave'] as bool? ?? true,
        autoSaveAmount: (json['autoSaveAmount'] as num?)?.toDouble() ?? 20.0,
        isLocked: json['isLocked'] as bool? ?? false,
      );
}

class TransactionItem {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isDeposit;
  final IconData icon;
  final String status;
  final String method;
  final String? category;

  TransactionItem({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isDeposit,
    required this.icon,
    this.status = 'Completed',
    this.method = 'MTN MoMo',
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'amount': amount,
        'isDeposit': isDeposit,
        'iconCode': icon.codePoint,
        'status': status,
        'method': method,
        'category': category,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      TransactionItem(
        id: json['id'] as String,
        title: json['title'] as String,
        date: json['date'] as String,
        amount: (json['amount'] as num).toDouble(),
        isDeposit: json['isDeposit'] as bool,
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          json['iconCode'] as int? ?? 0xe8b0,
          fontFamily: 'MaterialIcons',
        ),
        status: json['status'] as String? ?? 'Completed',
        method: json['method'] as String? ?? 'MTN MoMo',
        category: json['category'] as String?,
      );
}

class BudgetCategory {
  final String id;
  String name;
  double spent;
  double total;
  final IconData icon;
  final Color color;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.spent,
    required this.total,
    required this.icon,
    required this.color,
  });

  double get progress => total == 0 ? 0 : (spent / total).clamp(0.0, 1.0);
  bool get isOverBudget => spent > total;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'spent': spent,
        'total': total,
        'iconCode': icon.codePoint,
        'colorValue': _colorToInt(color),
      };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        spent: (json['spent'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          json['iconCode'] as int? ?? 0xe574,
          fontFamily: 'MaterialIcons',
        ),
        color: Color(json['colorValue'] as int? ?? 0xFF006E0A),
      );
}

int _colorToInt(Color color) {
  final a = (color.a * 255.0).round() & 0xff;
  final r = (color.r * 255.0).round() & 0xff;
  final g = (color.g * 255.0).round() & 0xff;
  final b = (color.b * 255.0).round() & 0xff;
  return (a << 24) | (r << 16) | (g << 8) | b;
}

class PaymentMethod {
  final String id;
  final String name;
  final String maskedNumber;
  final String type; // momo | bank
  final Color accent;
  bool isPrimary;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.maskedNumber,
    required this.type,
    required this.accent,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'maskedNumber': maskedNumber,
        'type': type,
        'accent': _colorToInt(accent),
        'isPrimary': isPrimary,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'] as String,
        name: json['name'] as String,
        maskedNumber: json['maskedNumber'] as String,
        type: json['type'] as String,
        accent: Color(json['accent'] as int? ?? 0xFFFFCC00),
        isPrimary: json['isPrimary'] as bool? ?? false,
      );
}

class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final Color bgColor;
  bool isUnread;
  final String? route;

  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.isUnread = true,
    this.route,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'time': time,
        'iconCode': icon.codePoint,
        'color': _colorToInt(color),
        'bgColor': _colorToInt(bgColor),
        'isUnread': isUnread,
        'route': route,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        time: json['time'] as String,
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          json['iconCode'] as int? ?? 0xe7f4,
          fontFamily: 'MaterialIcons',
        ),
        color: Color(json['color'] as int? ?? 0xFF006E0A),
        bgColor: Color(json['bgColor'] as int? ?? 0xFFE8F8EA),
        isUnread: json['isUnread'] as bool? ?? true,
        route: json['route'] as String?,
      );
}

class SusuGroup {
  final String id;
  final String name;
  final String role;
  final int members;
  final int yourPosition;
  final double poolAmount;
  final String nextPayout;
  final double contribution;
  final String frequency;

  SusuGroup({
    required this.id,
    required this.name,
    required this.role,
    required this.members,
    required this.yourPosition,
    required this.poolAmount,
    required this.nextPayout,
    required this.contribution,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'members': members,
        'yourPosition': yourPosition,
        'poolAmount': poolAmount,
        'nextPayout': nextPayout,
        'contribution': contribution,
        'frequency': frequency,
      };

  factory SusuGroup.fromJson(Map<String, dynamic> json) => SusuGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        members: json['members'] as int,
        yourPosition: json['yourPosition'] as int,
        poolAmount: (json['poolAmount'] as num).toDouble(),
        nextPayout: json['nextPayout'] as String,
        contribution: (json['contribution'] as num).toDouble(),
        frequency: json['frequency'] as String,
      );
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  static const _storageKey = 'kwanpa_susu_state_v1';

  // User
  String fullName = 'Kwame Mensah';
  String phone = '+233 54 123 4567';
  String pin = '1234';
  bool biometricEnabled = true;
  bool twoFactorEnabled = true;
  bool notificationsEnabled = true;
  String language = 'English (UK)';
  bool isAuthenticated = false;

  // Money
  double _totalBalance = 4300.00;
  double get totalBalance => _totalBalance;
  double get lockedSavings => _goals
      .where((g) => g.isLocked)
      .fold(0.0, (sum, g) => sum + g.currentSaved);
  double get totalNetWorth => _totalBalance + lockedSavings;

  // Loading / error
  bool isLoadingTransactions = true;
  bool isLoadingGoals = true;
  bool isLoadingPayments = true;
  bool hasLoadError = false;
  String? lastError;

  // Analytics
  bool analyticsWeekly = true;
  final List<double> weeklySpendFactors = [0.4, 0.55, 0.35, 0.85, 0.6, 0.7, 0.3];
  final List<double> monthlySpendFactors = [
    0.5,
    0.65,
    0.4,
    0.7,
    0.55,
    0.8,
    0.45,
    0.6,
    0.75,
    0.5,
    0.9,
    0.35,
  ];

  // Budget
  double monthlyIncome = 4500.00;
  final List<BudgetCategory> _budgetCategories = [
    BudgetCategory(
      id: 'b1',
      name: 'Susu & Savings',
      spent: 1000,
      total: 1000,
      icon: Icons.savings_rounded,
      color: const Color(0xFF006E0A),
    ),
    BudgetCategory(
      id: 'b2',
      name: 'Food & Groceries',
      spent: 850,
      total: 1200,
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFE65100),
    ),
    BudgetCategory(
      id: 'b3',
      name: 'Utilities & Bills',
      spent: 600,
      total: 700,
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFF0066CC),
    ),
    BudgetCategory(
      id: 'b4',
      name: 'Transport & Fuel',
      spent: 400,
      total: 600,
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF7B1FA2),
    ),
  ];

  List<BudgetCategory> get budgetCategories =>
      List.unmodifiable(_budgetCategories);
  double get totalExpenses =>
      _budgetCategories.fold(0.0, (s, c) => s + c.spent);
  double get remainingBudget => monthlyIncome - totalExpenses;
  double get budgetUsedPercent =>
      (totalExpenses / monthlyIncome).clamp(0.0, 1.0);

  final List<SusuGoal> _goals = [
    SusuGoal(
      id: 'g1',
      title: 'New House Deposit',
      targetAmount: 100000.00,
      currentSaved: 45000.00,
      frequency: 'Weekly',
      lockDate: 'Dec 2026',
      category: 'Real Estate',
      icon: Icons.cottage_outlined,
      autoSaveAmount: 500.00,
      isLocked: true,
    ),
    SusuGoal(
      id: 'g2',
      title: "Child's Education",
      targetAmount: 20000.00,
      currentSaved: 15000.00,
      frequency: 'Monthly',
      lockDate: 'Aug 2026',
      category: 'Education',
      icon: Icons.school_rounded,
      autoSaveAmount: 200.00,
      isLocked: true,
    ),
    SusuGoal(
      id: 'g3',
      title: 'Emergency Fund',
      targetAmount: 10000.00,
      currentSaved: 5000.00,
      frequency: 'Weekly',
      lockDate: 'Flexible',
      category: 'Safety',
      icon: Icons.shield_outlined,
      autoSaveAmount: 100.00,
      isLocked: false,
    ),
    SusuGoal(
      id: 'g4',
      title: 'Dubai Trip 2025',
      targetAmount: 12000.00,
      currentSaved: 2400.00,
      frequency: 'Weekly',
      lockDate: 'Jun 2025',
      category: 'Travel',
      icon: Icons.flight_outlined,
      autoSaveAmount: 50.00,
      isLocked: false,
    ),
  ];

  List<SusuGoal> get goals => List.unmodifiable(_goals);

  final List<TransactionItem> _transactions = [
    TransactionItem(
      id: 'tx1',
      title: 'Melcom Supermarket',
      date: 'Today, 14:30',
      amount: 250.00,
      isDeposit: false,
      icon: Icons.shopping_bag_outlined,
      method: 'MTN MoMo',
      category: 'Food & Groceries',
    ),
    TransactionItem(
      id: 'tx2',
      title: 'Salary Deposit',
      date: 'Yesterday',
      amount: 4500.00,
      isDeposit: true,
      icon: Icons.account_balance_wallet_outlined,
      method: 'Ecobank Visa',
      category: 'Income',
    ),
    TransactionItem(
      id: 'tx3',
      title: 'ECG Prepaid',
      date: '12 Oct',
      amount: 120.00,
      isDeposit: false,
      icon: Icons.electric_bolt_outlined,
      method: 'MTN MoMo',
      category: 'Utilities & Bills',
    ),
    TransactionItem(
      id: 'tx4',
      title: 'Deposit via MTN MoMo',
      date: 'Today, 2:15 PM',
      amount: 500.00,
      isDeposit: true,
      icon: Icons.south_west_rounded,
      method: 'MTN MoMo',
    ),
    TransactionItem(
      id: 'tx5',
      title: 'Auto-Save to New House Deposit',
      date: 'Yesterday, 9:00 AM',
      amount: 500.00,
      isDeposit: false,
      icon: Icons.savings_rounded,
      method: 'Susu Wallet',
    ),
  ];

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'pm1',
      name: 'MTN Mobile Money',
      maskedNumber: '024 *** 4567',
      type: 'momo',
      accent: const Color(0xFFFFCC00),
      isPrimary: true,
    ),
    PaymentMethod(
      id: 'pm2',
      name: 'Telecel Cash',
      maskedNumber: '050 *** 8819',
      type: 'momo',
      accent: const Color(0xFFE50012),
    ),
    PaymentMethod(
      id: 'pm3',
      name: 'Ecobank Visa Debit',
      maskedNumber: '•••• •••• •••• 4920',
      type: 'bank',
      accent: const Color(0xFF0066CC),
    ),
  ];

  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);
  PaymentMethod? get primaryPaymentMethod {
    try {
      return _paymentMethods.firstWhere((p) => p.isPrimary);
    } catch (_) {
      return _paymentMethods.isEmpty ? null : _paymentMethods.first;
    }
  }

  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      title: 'Emergency Fund Goal Reached 50%!',
      subtitle:
          'Great job! Keep contributing to hit your GHS 10,000 safety target.',
      time: '2h ago',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFC9A900),
      bgColor: const Color(0xFFFFF9C4),
      route: '/goal_detail',
    ),
    AppNotification(
      id: 'n2',
      title: 'Daily Susu Deposit Received',
      subtitle: 'GHS 50.00 credited to your Susu wallet from MTN MoMo.',
      time: '5h ago',
      icon: Icons.south_west_rounded,
      color: const Color(0xFF006E0A),
      bgColor: const Color(0xFFE8F8EA),
      isUnread: false,
      route: '/transactions',
    ),
    AppNotification(
      id: 'n3',
      title: 'Accra Traders Payout Update',
      subtitle:
          'You are #3 in line for the September 1st payout pool of GHS 12,000.00.',
      time: 'Yesterday',
      icon: Icons.groups_rounded,
      color: const Color(0xFFE65100),
      bgColor: const Color(0xFFFFF3E0),
      isUnread: false,
      route: '/groups',
    ),
    AppNotification(
      id: 'n4',
      title: 'Successful Device Login',
      subtitle:
          'New login detected from Kwanpa Susu Mobile App on Android device.',
      time: 'Aug 2, 2026',
      icon: Icons.shield_rounded,
      color: const Color(0xFF0066CC),
      bgColor: const Color(0xFFE6F4FF),
      isUnread: false,
    ),
  ];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((n) => n.isUnread).length;

  final List<SusuGroup> _groups = [
    SusuGroup(
      id: 'gr1',
      name: 'Accra Traders Circle',
      role: 'Member',
      members: 12,
      yourPosition: 3,
      poolAmount: 12000.00,
      nextPayout: 'Sep 1, 2026',
      contribution: 1000.00,
      frequency: 'Monthly',
    ),
    SusuGroup(
      id: 'gr2',
      name: 'Family Susu 2026',
      role: 'Admin',
      members: 6,
      yourPosition: 1,
      poolAmount: 3600.00,
      nextPayout: 'Aug 15, 2026',
      contribution: 600.00,
      frequency: 'Weekly',
    ),
  ];

  List<SusuGroup> get groups => List.unmodifiable(_groups);

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'KS';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'Friend' : parts.first;
  }

  Future<void> init() async {
    await _loadFromStorage();
    await simulateLoading();
  }

  Future<void> simulateLoading({bool fail = false}) async {
    isLoadingTransactions = true;
    isLoadingGoals = true;
    isLoadingPayments = true;
    hasLoadError = false;
    lastError = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    if (fail) {
      hasLoadError = true;
      lastError = 'Could not refresh data. Check your connection and try again.';
      isLoadingTransactions = false;
      isLoadingGoals = false;
      isLoadingPayments = false;
      notifyListeners();
      return;
    }

    isLoadingTransactions = false;
    isLoadingGoals = false;
    isLoadingPayments = false;
    notifyListeners();
  }

  Future<void> retryLoad() => simulateLoading();

  bool deposit(double amount, String method) {
    if (amount <= 0) {
      lastError = 'Enter a valid deposit amount.';
      notifyListeners();
      return false;
    }
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
    _pushNotification(
      title: 'Deposit Successful',
      subtitle: 'GHS ${amount.toStringAsFixed(2)} added via $method.',
      icon: Icons.south_west_rounded,
      color: const Color(0xFF006E0A),
      bgColor: const Color(0xFFE8F8EA),
      route: '/transactions',
    );
    _persist();
    notifyListeners();
    return true;
  }

  bool withdraw(double amount, String destination) {
    if (amount <= 0) {
      lastError = 'Enter a valid withdrawal amount.';
      notifyListeners();
      return false;
    }
    if (_totalBalance < amount) {
      lastError = 'Amount exceeds available wallet balance.';
      notifyListeners();
      return false;
    }
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
    _pushNotification(
      title: 'Withdrawal Sent',
      subtitle: 'GHS ${amount.toStringAsFixed(2)} sent to $destination.',
      icon: Icons.north_east_rounded,
      color: const Color(0xFF0066CC),
      bgColor: const Color(0xFFE6F4FF),
      route: '/transactions',
    );
    _persist();
    notifyListeners();
    return true;
  }

  void addGoal({
    required String title,
    required double targetAmount,
    required String frequency,
    required String lockDate,
    bool isLocked = true,
    double autoSaveAmount = 25.00,
    bool isAutoSave = true,
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
        isLocked: isLocked,
        autoSaveAmount: autoSaveAmount,
        isAutoSave: isAutoSave,
      ),
    );
    _pushNotification(
      title: 'New Goal Created',
      subtitle: '“$title” is ready. Start contributing today.',
      icon: Icons.flag_rounded,
      color: const Color(0xFF006E0A),
      bgColor: const Color(0xFFE8F8EA),
      route: '/goal_detail',
    );
    _persist();
    notifyListeners();
  }

  bool contributeToGoal(String goalId, double amount) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) {
      lastError = 'Goal not found.';
      notifyListeners();
      return false;
    }
    if (amount <= 0) {
      lastError = 'Enter a valid amount.';
      notifyListeners();
      return false;
    }
    if (_totalBalance < amount) {
      lastError = 'Insufficient wallet balance.';
      notifyListeners();
      return false;
    }

    final goal = _goals[index];
    _totalBalance -= amount;
    goal.currentSaved += amount;
    _transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Contributed to ${goal.title}',
        date: 'Just now',
        amount: amount,
        isDeposit: false,
        icon: Icons.savings_rounded,
        method: 'Susu Wallet',
      ),
    );

    if (goal.isAchieved) {
      _pushNotification(
        title: 'Goal Achieved!',
        subtitle: 'You hit ${goal.title}. Celebrate and set the next one.',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFC9A900),
        bgColor: const Color(0xFFFFF9C4),
        route: '/goal_achieved',
      );
    }

    _persist();
    notifyListeners();
    return true;
  }

  SusuGoal? goalById(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void addBudgetCategory(String name, double total) {
    _budgetCategories.add(
      BudgetCategory(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        spent: 0,
        total: total,
        icon: Icons.category_rounded,
        color: const Color(0xFF00730B),
      ),
    );
    _persist();
    notifyListeners();
  }

  void updateBudgetCategory(String id, {String? name, double? total}) {
    final i = _budgetCategories.indexWhere((c) => c.id == id);
    if (i == -1) return;
    if (name != null) _budgetCategories[i].name = name;
    if (total != null) _budgetCategories[i].total = total;
    _persist();
    notifyListeners();
  }

  void removeBudgetCategory(String id) {
    _budgetCategories.removeWhere((c) => c.id == id);
    _persist();
    notifyListeners();
  }

  void addPaymentMethod({
    required String name,
    required String maskedNumber,
    required String type,
    required Color accent,
  }) {
    _paymentMethods.add(
      PaymentMethod(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        maskedNumber: maskedNumber,
        type: type,
        accent: accent,
        isPrimary: _paymentMethods.isEmpty,
      ),
    );
    _persist();
    notifyListeners();
  }

  void removePaymentMethod(String id) {
    _paymentMethods.removeWhere((p) => p.id == id);
    if (_paymentMethods.isNotEmpty &&
        !_paymentMethods.any((p) => p.isPrimary)) {
      _paymentMethods.first.isPrimary = true;
    }
    _persist();
    notifyListeners();
  }

  void setPrimaryPaymentMethod(String id) {
    for (final p in _paymentMethods) {
      p.isPrimary = p.id == id;
    }
    _persist();
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final i = _notifications.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _notifications[i].isUnread = false;
    _persist();
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in _notifications) {
      n.isUnread = false;
    }
    _persist();
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    _persist();
    notifyListeners();
  }

  void setBiometricEnabled(bool value) {
    biometricEnabled = value;
    _persist();
    notifyListeners();
  }

  void setTwoFactorEnabled(bool value) {
    twoFactorEnabled = value;
    _persist();
    notifyListeners();
  }

  void setLanguage(String value) {
    language = value;
    _persist();
    notifyListeners();
  }

  void updateProfile({String? name, String? phoneNumber}) {
    if (name != null && name.trim().isNotEmpty) fullName = name.trim();
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      phone = phoneNumber.trim();
    }
    _persist();
    notifyListeners();
  }

  bool verifyPin(String entered) => entered == pin;

  bool changePin(String current, String next) {
    if (current != pin) {
      lastError = 'Current PIN is incorrect.';
      notifyListeners();
      return false;
    }
    if (next.length != 4) {
      lastError = 'New PIN must be 4 digits.';
      notifyListeners();
      return false;
    }
    pin = next;
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  void setPin(String next) {
    pin = next;
    _persist();
    notifyListeners();
  }

  void signIn() {
    isAuthenticated = true;
    _persist();
    notifyListeners();
  }

  void signOut() {
    isAuthenticated = false;
    _persist();
    notifyListeners();
  }

  void setAnalyticsWeekly(bool weekly) {
    analyticsWeekly = weekly;
    notifyListeners();
  }

  void addGroup({
    required String name,
    required double contribution,
    required String frequency,
    int members = 5,
  }) {
    _groups.insert(
      0,
      SusuGroup(
        id: 'gr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        role: 'Admin',
        members: members,
        yourPosition: 1,
        poolAmount: contribution * members,
        nextPayout: 'TBD',
        contribution: contribution,
        frequency: frequency,
      ),
    );
    _pushNotification(
      title: 'Group Created',
      subtitle: '“$name” is ready. Invite members to start saving together.',
      icon: Icons.groups_rounded,
      color: const Color(0xFFE65100),
      bgColor: const Color(0xFFFFF3E0),
      route: '/groups',
    );
    _persist();
    notifyListeners();
  }

  void clearError() {
    lastError = null;
    notifyListeners();
  }

  void _pushNotification({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    String? route,
  }) {
    if (!notificationsEnabled) return;
    _notifications.insert(
      0,
      AppNotification(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subtitle: subtitle,
        time: 'Just now',
        icon: icon,
        color: color,
        bgColor: bgColor,
        route: route,
      ),
    );
  }

  IconData _selectIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('car') || lower.contains('vehicle')) {
      return Icons.directions_car_rounded;
    }
    if (lower.contains('house') ||
        lower.contains('rent') ||
        lower.contains('home')) {
      return Icons.home_rounded;
    }
    if (lower.contains('phone') ||
        lower.contains('tech') ||
        lower.contains('laptop')) {
      return Icons.devices_rounded;
    }
    if (lower.contains('school') ||
        lower.contains('fee') ||
        lower.contains('education')) {
      return Icons.school_rounded;
    }
    if (lower.contains('trip') ||
        lower.contains('vacation') ||
        lower.contains('travel') ||
        lower.contains('dubai')) {
      return Icons.flight_takeoff_rounded;
    }
    return Icons.savings_rounded;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'fullName': fullName,
        'phone': phone,
        'pin': pin,
        'biometricEnabled': biometricEnabled,
        'twoFactorEnabled': twoFactorEnabled,
        'notificationsEnabled': notificationsEnabled,
        'language': language,
        'isAuthenticated': isAuthenticated,
        'totalBalance': _totalBalance,
        'monthlyIncome': monthlyIncome,
        'goals': _goals.map((g) => g.toJson()).toList(),
        'transactions': _transactions.map((t) => t.toJson()).toList(),
        'budgetCategories': _budgetCategories.map((b) => b.toJson()).toList(),
        'paymentMethods': _paymentMethods.map((p) => p.toJson()).toList(),
        'notifications': _notifications.map((n) => n.toJson()).toList(),
        'groups': _groups.map((g) => g.toJson()).toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (_) {
      // Local persistence is best-effort for the demo frontend.
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;

      fullName = data['fullName'] as String? ?? fullName;
      phone = data['phone'] as String? ?? phone;
      pin = data['pin'] as String? ?? pin;
      biometricEnabled = data['biometricEnabled'] as bool? ?? biometricEnabled;
      twoFactorEnabled = data['twoFactorEnabled'] as bool? ?? twoFactorEnabled;
      notificationsEnabled =
          data['notificationsEnabled'] as bool? ?? notificationsEnabled;
      language = data['language'] as String? ?? language;
      isAuthenticated = data['isAuthenticated'] as bool? ?? false;
      _totalBalance =
          (data['totalBalance'] as num?)?.toDouble() ?? _totalBalance;
      monthlyIncome =
          (data['monthlyIncome'] as num?)?.toDouble() ?? monthlyIncome;

      if (data['goals'] is List) {
        _goals
          ..clear()
          ..addAll(
            (data['goals'] as List)
                .map((e) => SusuGoal.fromJson(e as Map<String, dynamic>)),
          );
      }
      if (data['transactions'] is List) {
        _transactions
          ..clear()
          ..addAll(
            (data['transactions'] as List).map(
              (e) => TransactionItem.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      if (data['budgetCategories'] is List) {
        _budgetCategories
          ..clear()
          ..addAll(
            (data['budgetCategories'] as List).map(
              (e) => BudgetCategory.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      if (data['paymentMethods'] is List) {
        _paymentMethods
          ..clear()
          ..addAll(
            (data['paymentMethods'] as List).map(
              (e) => PaymentMethod.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      if (data['notifications'] is List) {
        _notifications
          ..clear()
          ..addAll(
            (data['notifications'] as List).map(
              (e) => AppNotification.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      if (data['groups'] is List) {
        _groups
          ..clear()
          ..addAll(
            (data['groups'] as List)
                .map((e) => SusuGroup.fromJson(e as Map<String, dynamic>)),
          );
      }
      notifyListeners();
    } catch (_) {
      // Ignore corrupt storage and keep seeded defaults.
    }
  }
}
