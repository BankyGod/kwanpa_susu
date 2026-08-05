import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SusuGoal {
  final String id;
  String? _title;
  final double targetAmount;
  double currentSaved;
  String? _frequency;
  String? _lockDate;
  String? _category;
  final IconData icon;
  final bool isAutoSave;
  final double autoSaveAmount;
  /// `flexible` — withdraw anytime, no penalty.
  /// `strict` — early withdraw allowed with a 15% platform fee until unlock date.
  String? _lockType;

  static const double earlyWithdrawalPenaltyRate = 0.15;

  SusuGoal({
    required this.id,
    required String title,
    required this.targetAmount,
    required this.currentSaved,
    required String frequency,
    required String lockDate,
    String category = 'Personal',
    this.icon = Icons.savings_rounded,
    this.isAutoSave = true,
    this.autoSaveAmount = 20.00,
    bool? isLocked,
    String? lockType,
  })  : _title = title,
        _frequency = frequency,
        _lockDate = lockDate,
        _category = category,
        _lockType = lockType ??
            ((isLocked ?? false) ? 'strict' : 'flexible');

  String get title => _title ?? 'Savings Goal';
  set title(String value) => _title = value;

  String get frequency => _frequency ?? 'Weekly';
  set frequency(String value) => _frequency = value;

  String get lockDate => _lockDate ?? 'Flexible';
  set lockDate(String value) => _lockDate = value;

  String get category => _category ?? 'Personal';
  set category(String value) => _category = value;

  String get lockType {
    final t = _lockType;
    if (t == 'strict') return 'strict';
    if (t == 'flexible') return 'flexible';
    return 'flexible';
  }

  set lockType(String value) => _lockType = value;

  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return (currentSaved / targetAmount).clamp(0.0, 1.0);
  }

  bool get isAchieved => currentSaved >= targetAmount;
  bool get isStrict => lockType == 'strict';
  bool get isFlexible => !isStrict;
  /// Kept for older UI: strict goals are the locked savings product.
  bool get isLocked => isStrict;

  DateTime? get unlockDate => parseGoalLockDate(lockDate);

  bool get isUnlockDue {
    if (isFlexible) return true;
    final due = unlockDate;
    if (due == null) return false;
    final today = DateTime.now();
    final dueDay = DateTime(due.year, due.month, due.day);
    return !today.isBefore(dueDay);
  }

  bool get appliesEarlyPenalty => isStrict && !isUnlockDue;

  double earlyPenaltyFor(double amount) =>
      appliesEarlyPenalty ? amount * earlyWithdrawalPenaltyRate : 0;

  double netAfterWithdraw(double amount) =>
      amount - earlyPenaltyFor(amount);

  String get lockTypeLabel => isStrict ? 'Strict' : 'Flexible';

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
        'lockType': lockType,
      };

  factory SusuGoal.fromJson(Map<String, dynamic> json) {
    final storedType = json['lockType'] as String?;
    final legacyLocked = json['isLocked'] as bool? ?? false;
    return SusuGoal(
      id: json['id'] as String? ?? 'g_unknown',
      title: json['title'] as String? ?? 'Savings Goal',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      currentSaved: (json['currentSaved'] as num?)?.toDouble() ?? 0,
      frequency: json['frequency'] as String? ?? 'Weekly',
      lockDate: json['lockDate'] as String? ?? 'Flexible',
      category: json['category'] as String? ?? 'Personal',
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        json['iconCode'] as int? ?? 0xe53e,
        fontFamily: 'MaterialIcons',
      ),
      isAutoSave: json['isAutoSave'] as bool? ?? true,
      autoSaveAmount: (json['autoSaveAmount'] as num?)?.toDouble() ?? 20.0,
      lockType: storedType ?? (legacyLocked ? 'strict' : 'flexible'),
    );
  }
}

DateTime? parseGoalLockDate(String raw) {
  final t = raw.trim();
  if (t.isEmpty || t.toLowerCase() == 'flexible') return null;

  final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(t);
  if (slash != null) {
    return DateTime(
      int.parse(slash.group(3)!),
      int.parse(slash.group(1)!),
      int.parse(slash.group(2)!),
    );
  }

  const months = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final month = months[parts[0].toLowerCase()];
    final year = int.tryParse(parts.last);
    if (month != null && year != null) {
      final day = parts.length >= 3
          ? int.tryParse(parts[1].replaceAll(',', '')) ??
              DateTime(year, month + 1, 0).day
          : DateTime(year, month + 1, 0).day;
      return DateTime(year, month, day);
    }
  }
  return null;
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
  final Object? routeArgs;

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
    this.routeArgs,
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
        'routeArgs': routeArgs is String ? routeArgs : null,
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
        routeArgs: json['routeArgs'],
      );
}

class GroupLedgerEntry {
  final String id;
  final String title;
  final String memberName;
  final double amount;
  final String date;
  final String type; // contribution | payout | skip

  GroupLedgerEntry({
    required this.id,
    required this.title,
    required this.memberName,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'memberName': memberName,
        'amount': amount,
        'date': date,
        'type': type,
      };

  factory GroupLedgerEntry.fromJson(Map<String, dynamic> json) =>
      GroupLedgerEntry(
        id: json['id'] as String? ?? 'led_unknown',
        title: json['title'] as String? ?? '',
        memberName: json['memberName'] as String? ?? 'Member',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        date: json['date'] as String? ?? '',
        type: json['type'] as String? ?? 'contribution',
      );
}

class GroupMember {
  final String id;
  String? _name;
  String? _phone;
  final int position;
  bool hasPaidThisRound;
  final bool isYou;
  String? _status; // active | pending
  bool skippedThisCycle;
  bool hasReceivedPayout;
  int cycleContributions;

  GroupMember({
    required this.id,
    required String name,
    required String phone,
    required this.position,
    this.hasPaidThisRound = false,
    this.isYou = false,
    String status = 'active',
    this.skippedThisCycle = false,
    this.hasReceivedPayout = false,
    this.cycleContributions = 0,
  })  : _name = name,
        _phone = phone,
        _status = status;

  String get name => _name ?? 'Member';
  set name(String value) => _name = value;

  String get phone => _phone ?? '';
  set phone(String value) => _phone = value;

  String get status => _status ?? 'active';
  set status(String value) => _status = value;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'position': position,
        'hasPaidThisRound': hasPaidThisRound,
        'isYou': isYou,
        'status': status,
        'skippedThisCycle': skippedThisCycle,
        'hasReceivedPayout': hasReceivedPayout,
        'cycleContributions': cycleContributions,
      };

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
        id: json['id'] as String? ?? 'm_unknown',
        name: json['name'] as String? ?? 'Member',
        phone: json['phone'] as String? ?? '',
        position: json['position'] as int? ?? 1,
        hasPaidThisRound: json['hasPaidThisRound'] as bool? ?? false,
        isYou: json['isYou'] as bool? ?? false,
        status: json['status'] as String? ?? 'active',
        skippedThisCycle: json['skippedThisCycle'] as bool? ?? false,
        hasReceivedPayout: json['hasReceivedPayout'] as bool? ?? false,
        cycleContributions: json['cycleContributions'] as int? ?? 0,
      );
}

class GroupMessage {
  final String id;
  String? _senderName;
  String? _text;
  String? _time;
  final bool isSystem;
  final bool isYou;

  GroupMessage({
    required this.id,
    required String senderName,
    required String text,
    required String time,
    this.isSystem = false,
    this.isYou = false,
  })  : _senderName = senderName,
        _text = text,
        _time = time;

  String get senderName => _senderName ?? 'Member';
  String get text => _text ?? '';
  String get time => _time ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderName': senderName,
        'text': text,
        'time': time,
        'isSystem': isSystem,
        'isYou': isYou,
      };

  factory GroupMessage.fromJson(Map<String, dynamic> json) => GroupMessage(
        id: json['id'] as String? ?? 'msg_unknown',
        senderName: json['senderName'] as String? ?? 'Member',
        text: json['text'] as String? ?? '',
        time: json['time'] as String? ?? '',
        isSystem: json['isSystem'] as bool? ?? false,
        isYou: json['isYou'] as bool? ?? false,
      );
}

class RotationSlot {
  final int position;
  String? _memberName;
  String? _payoutDate;
  bool isPaidOut;
  bool isCurrent;

  RotationSlot({
    required this.position,
    required String memberName,
    required String payoutDate,
    this.isPaidOut = false,
    this.isCurrent = false,
  })  : _memberName = memberName,
        _payoutDate = payoutDate;

  String get memberName => _memberName ?? 'Member';
  set memberName(String value) => _memberName = value;

  String get payoutDate => _payoutDate ?? 'TBD';
  set payoutDate(String value) => _payoutDate = value;

  Map<String, dynamic> toJson() => {
        'position': position,
        'memberName': memberName,
        'payoutDate': payoutDate,
        'isPaidOut': isPaidOut,
        'isCurrent': isCurrent,
      };

  factory RotationSlot.fromJson(Map<String, dynamic> json) => RotationSlot(
        position: json['position'] as int? ?? 1,
        memberName: json['memberName'] as String? ?? 'Member',
        payoutDate: json['payoutDate'] as String? ?? 'TBD',
        isPaidOut: json['isPaidOut'] as bool? ?? false,
        isCurrent: json['isCurrent'] as bool? ?? false,
      );
}

class SusuGroup {
  final String id;
  String? _name;
  String? _role;
  int yourPosition;
  double poolAmount;
  String? _nextPayout;
  double contribution;
  String? _frequency;
  double collectedThisRound;
  String? _inviteCode;
  bool youHavePaidThisRound;
  bool isArchived;
  int unreadChatCount;
  List<GroupMember>? _memberList;
  List<GroupMessage>? _messages;
  List<String>? _rules;
  List<RotationSlot>? _schedule;
  List<GroupLedgerEntry>? _contributionHistory;
  List<GroupLedgerEntry>? _payoutHistory;

  SusuGroup({
    required this.id,
    required String name,
    required String role,
    required this.yourPosition,
    required this.poolAmount,
    required String nextPayout,
    required this.contribution,
    required String frequency,
    this.collectedThisRound = 0,
    String inviteCode = '',
    this.youHavePaidThisRound = false,
    this.isArchived = false,
    this.unreadChatCount = 0,
    List<GroupMember>? memberList,
    List<GroupMessage>? messages,
    List<String>? rules,
    List<RotationSlot>? schedule,
    List<GroupLedgerEntry>? contributionHistory,
    List<GroupLedgerEntry>? payoutHistory,
  })  : _name = name,
        _role = role,
        _nextPayout = nextPayout,
        _frequency = frequency,
        _inviteCode = inviteCode,
        _memberList = List<GroupMember>.from(memberList ?? const []),
        _messages = List<GroupMessage>.from(messages ?? const []),
        _rules = List<String>.from(rules ?? const []),
        _schedule = List<RotationSlot>.from(schedule ?? const []),
        _contributionHistory =
            List<GroupLedgerEntry>.from(contributionHistory ?? const []),
        _payoutHistory = List<GroupLedgerEntry>.from(payoutHistory ?? const []);

  String get name => _name ?? 'Group Susu';
  set name(String value) => _name = value;

  String get role => _role ?? 'Member';
  set role(String value) => _role = value;

  String get nextPayout => _nextPayout ?? 'TBD';
  set nextPayout(String value) => _nextPayout = value;

  String get frequency => _frequency ?? 'Weekly';
  set frequency(String value) => _frequency = value;

  String get inviteCode => _inviteCode ?? 'KS-0000';
  set inviteCode(String value) => _inviteCode = value;

  List<GroupMember> get memberList {
    _memberList ??= <GroupMember>[];
    return _memberList!;
  }

  set memberList(List<GroupMember> value) =>
      _memberList = List<GroupMember>.from(value);

  List<GroupMessage> get messages {
    _messages ??= <GroupMessage>[];
    return _messages!;
  }

  set messages(List<GroupMessage> value) =>
      _messages = List<GroupMessage>.from(value);

  List<String> get rules {
    _rules ??= <String>[];
    return _rules!;
  }

  set rules(List<String> value) => _rules = List<String>.from(value);

  List<RotationSlot> get schedule {
    _schedule ??= <RotationSlot>[];
    return _schedule!;
  }

  set schedule(List<RotationSlot> value) =>
      _schedule = List<RotationSlot>.from(value);

  List<GroupLedgerEntry> get contributionHistory {
    _contributionHistory ??= <GroupLedgerEntry>[];
    return _contributionHistory!;
  }

  set contributionHistory(List<GroupLedgerEntry> value) =>
      _contributionHistory = List<GroupLedgerEntry>.from(value);

  List<GroupLedgerEntry> get payoutHistory {
    _payoutHistory ??= <GroupLedgerEntry>[];
    return _payoutHistory!;
  }

  set payoutHistory(List<GroupLedgerEntry> value) =>
      _payoutHistory = List<GroupLedgerEntry>.from(value);

  void ensureCollections() {
    _name ??= 'Group Susu';
    _role ??= 'Member';
    _nextPayout ??= 'TBD';
    _frequency ??= 'Weekly';
    _inviteCode ??= 'KS-${id.hashCode.abs() % 9000 + 1000}';
    _memberList ??= <GroupMember>[];
    _messages ??= <GroupMessage>[];
    _rules ??= <String>[
      'Contribute on time every cycle.',
      'Missed payments may skip your payout turn.',
      'Payouts follow the rotation schedule.',
    ];
    _schedule ??= <RotationSlot>[];
    _contributionHistory ??= <GroupLedgerEntry>[];
    _payoutHistory ??= <GroupLedgerEntry>[];
  }

  bool get isHealthy {
    try {
      return name.isNotEmpty && inviteCode.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  int get members =>
      memberList.where((m) => (m.status) == 'active').length;
  int get pendingInvites =>
      memberList.where((m) => (m.status) == 'pending').length;
  int get unpaidActiveCount => memberList
      .where((m) => m.status == 'active' && !m.hasPaidThisRound && !m.skippedThisCycle)
      .length;
  double get roundTarget {
    final paying = memberList
        .where((m) => m.status == 'active' && !m.skippedThisCycle)
        .length;
    return contribution * (paying == 0 ? 1 : paying);
  }
  double get roundProgress =>
      roundTarget == 0 ? 0 : (collectedThisRound / roundTarget).clamp(0.0, 1.0);
  bool get isYourPayoutTurn {
    final current = schedule.where((s) => s.isCurrent).toList();
    if (current.isEmpty) return yourPosition == 1;
    return current.first.position == yourPosition && !current.first.isPaidOut;
  }

  bool get canClaimPayout =>
      isYourPayoutTurn && collectedThisRound >= roundTarget && roundTarget > 0;

  bool get isCycleComplete =>
      schedule.isNotEmpty && schedule.every((s) => s.isPaidOut);

  /// Fair-exit rules for leave/remove (frontend trust locks).
  String? exitBlockReason(GroupMember m) {
    if (m.status == 'pending') return null;
    if (m.hasPaidThisRound) {
      return 'Cannot leave or be removed while this round’s contribution is still in the pot.';
    }
    if (m.hasReceivedPayout && !isCycleComplete) {
      return 'After receiving a payout, you must keep contributing until the full rotation finishes.';
    }
    if (m.cycleContributions > 0 && !m.hasReceivedPayout && !isCycleComplete) {
      return 'This member has already paid into the cycle and is still waiting for their turn.';
    }
    return null;
  }

  bool get canYouLeave {
    try {
      final you = memberList.firstWhere((m) => m.isYou);
      return exitBlockReason(you) == null;
    } catch (_) {
      return true;
    }
  }

  String get payoutBlockReason {
    if (canClaimPayout) return '';
    if (!isYourPayoutTurn) {
      return 'It is not your turn on the rotation schedule yet.';
    }
    return 'Round is ${collectedThisRound.toStringAsFixed(0)} / ${roundTarget.toStringAsFixed(0)}. Waiting for remaining contributions.';
  }

  String get contributeBlockReason {
    if (!youHavePaidThisRound) return '';
    return 'You already contributed for this round.';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'yourPosition': yourPosition,
        'poolAmount': poolAmount,
        'nextPayout': nextPayout,
        'contribution': contribution,
        'frequency': frequency,
        'collectedThisRound': collectedThisRound,
        'inviteCode': inviteCode,
        'youHavePaidThisRound': youHavePaidThisRound,
        'isArchived': isArchived,
        'unreadChatCount': unreadChatCount,
        'memberList': memberList.map((m) => m.toJson()).toList(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'rules': rules,
        'schedule': schedule.map((s) => s.toJson()).toList(),
        'contributionHistory':
            contributionHistory.map((e) => e.toJson()).toList(),
        'payoutHistory': payoutHistory.map((e) => e.toJson()).toList(),
      };

  factory SusuGroup.fromJson(Map<String, dynamic> json) {
    final memberCount = json['members'] as int? ?? 0;
    List<GroupMember> parsedMembers = [];
    if (json['memberList'] is List) {
      for (final e in json['memberList'] as List) {
        if (e is Map<String, dynamic>) {
          parsedMembers.add(GroupMember.fromJson(e));
        } else if (e is Map) {
          parsedMembers.add(
            GroupMember.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    if (parsedMembers.isEmpty && memberCount > 0) {
      parsedMembers = List.generate(
        memberCount.clamp(1, 20),
        (i) => GroupMember(
          id: 'm_$i',
          name: i == 0 ? 'You' : 'Member ${i + 1}',
          phone: '',
          position: i + 1,
          isYou: i == 0,
        ),
      );
    }

    List<GroupMessage> parsedMessages = [];
    if (json['messages'] is List) {
      for (final e in json['messages'] as List) {
        if (e is Map<String, dynamic>) {
          parsedMessages.add(GroupMessage.fromJson(e));
        } else if (e is Map) {
          parsedMessages.add(
            GroupMessage.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }

    List<RotationSlot> parsedSchedule = [];
    if (json['schedule'] is List) {
      for (final e in json['schedule'] as List) {
        if (e is Map<String, dynamic>) {
          parsedSchedule.add(RotationSlot.fromJson(e));
        } else if (e is Map) {
          parsedSchedule.add(
            RotationSlot.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }

    final parsedRules = json['rules'] is List
        ? (json['rules'] as List).map((e) => e.toString()).toList()
        : <String>[
            'Contribute on time every cycle.',
            'Missed payments may skip your payout turn.',
            'Payouts follow the rotation schedule.',
          ];

    List<GroupLedgerEntry> parseLedger(String key) {
      final out = <GroupLedgerEntry>[];
      if (json[key] is List) {
        for (final e in json[key] as List) {
          if (e is Map<String, dynamic>) {
            out.add(GroupLedgerEntry.fromJson(e));
          } else if (e is Map) {
            out.add(GroupLedgerEntry.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
      return out;
    }

    final id = json['id'] as String? ?? 'gr_unknown';
    return SusuGroup(
      id: id,
      name: json['name'] as String? ?? 'Group Susu',
      role: json['role'] as String? ?? 'Member',
      yourPosition: json['yourPosition'] as int? ?? 1,
      poolAmount: (json['poolAmount'] as num?)?.toDouble() ?? 0,
      nextPayout: json['nextPayout'] as String? ?? 'TBD',
      contribution: (json['contribution'] as num?)?.toDouble() ?? 0,
      frequency: json['frequency'] as String? ?? 'Weekly',
      collectedThisRound:
          (json['collectedThisRound'] as num?)?.toDouble() ?? 0,
      inviteCode: json['inviteCode'] as String? ??
          'KS-${id.hashCode.abs() % 9000 + 1000}',
      youHavePaidThisRound: json['youHavePaidThisRound'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      unreadChatCount: json['unreadChatCount'] as int? ?? 0,
      memberList: parsedMembers,
      messages: parsedMessages,
      rules: parsedRules,
      schedule: parsedSchedule,
      contributionHistory: parseLedger('contributionHistory'),
      payoutHistory: parseLedger('payoutHistory'),
    );
  }
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  static const _storageKey = 'kwanpa_susu_state_v6';

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
  bool isLoadingGroups = true;
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
      lockType: 'strict',
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
      lockType: 'strict',
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
      lockType: 'flexible',
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
      lockType: 'flexible',
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

  static const int _groupModelVersion = 6;
  int? _activeGroupModelVersion;
  final List<SusuGroup> _groups = [];

  List<SusuGroup> get groups {
    _ensureGroupModel();
    return List.unmodifiable(_groups);
  }

  void _ensureGroupModel() {
    final healthy = _groups.isNotEmpty &&
        _activeGroupModelVersion == _groupModelVersion &&
        _groups.every((g) {
          try {
            g.ensureCollections();
            return g.isHealthy;
          } catch (_) {
            return false;
          }
        });
    if (healthy) return;
    _groups
      ..clear()
      ..addAll(_seedGroups());
    _activeGroupModelVersion = _groupModelVersion;
  }

  List<SusuGroup> _seedGroups() => [
    SusuGroup(
      id: 'gr1',
      name: 'Accra Traders Circle',
      role: 'Member',
      yourPosition: 3,
      poolAmount: 12000.00,
      nextPayout: 'Sep 1, 2026',
      contribution: 1000.00,
      frequency: 'Monthly',
      collectedThisRound: 8000.00,
      inviteCode: 'KS-4821',
      youHavePaidThisRound: true,
      unreadChatCount: 1,
      memberList: [
        GroupMember(
            id: 'gr1_m1',
            name: 'Ama Boateng',
            phone: '024 *** 1102',
            position: 1,
            hasPaidThisRound: true,
            hasReceivedPayout: true,
            cycleContributions: 3),
        GroupMember(
            id: 'gr1_m2',
            name: 'Kojo Asante',
            phone: '050 *** 3344',
            position: 2,
            hasPaidThisRound: true,
            hasReceivedPayout: true,
            cycleContributions: 3),
        GroupMember(
            id: 'gr1_m3',
            name: 'Kwame Mensah',
            phone: '054 *** 4567',
            position: 3,
            hasPaidThisRound: true,
            isYou: true,
            cycleContributions: 2),
        GroupMember(
            id: 'gr1_m4',
            name: 'Efua Mensah',
            phone: '027 *** 8899',
            position: 4,
            hasPaidThisRound: true),
        GroupMember(
            id: 'gr1_m5',
            name: 'Yaw Owusu',
            phone: '024 *** 2211',
            position: 5,
            hasPaidThisRound: false),
        GroupMember(
            id: 'gr1_m6',
            name: 'Akosua Darko',
            phone: '055 *** 6677',
            position: 6,
            hasPaidThisRound: false),
        GroupMember(
            id: 'gr1_m7',
            name: 'Pending invite',
            phone: '020 *** 0000',
            position: 7,
            status: 'pending'),
      ],
      messages: [
        GroupMessage(
          id: 'msg1',
          senderName: 'System',
          text: 'Round contributions are due by Aug 28.',
          time: 'Yesterday',
          isSystem: true,
        ),
        GroupMessage(
          id: 'msg2',
          senderName: 'Ama Boateng',
          text: 'Paid mine this morning. Who is next?',
          time: '10:12 AM',
        ),
        GroupMessage(
          id: 'msg3',
          senderName: 'You',
          text: 'I have paid as well. Looking good for Sep 1.',
          time: '10:20 AM',
          isYou: true,
        ),
      ],
      rules: [
        'Monthly contribution of GHS 1,000 due by the 28th.',
        'Missed payment skips your next payout turn.',
        'Only the scheduled member can claim the round payout.',
        'After receiving payout, keep contributing until the full rotation ends.',
        'Admin cannot remove members who have paid in or received payout mid-cycle.',
        'Invite-only — share the group code with trusted people.',
      ],
      schedule: [
        RotationSlot(
            position: 1,
            memberName: 'Ama Boateng',
            payoutDate: 'Jul 1, 2026',
            isPaidOut: true),
        RotationSlot(
            position: 2,
            memberName: 'Kojo Asante',
            payoutDate: 'Aug 1, 2026',
            isPaidOut: true),
        RotationSlot(
            position: 3,
            memberName: 'Kwame Mensah (You)',
            payoutDate: 'Sep 1, 2026',
            isCurrent: true),
        RotationSlot(
            position: 4,
            memberName: 'Efua Mensah',
            payoutDate: 'Oct 1, 2026'),
        RotationSlot(
            position: 5,
            memberName: 'Yaw Owusu',
            payoutDate: 'Nov 1, 2026'),
        RotationSlot(
            position: 6,
            memberName: 'Akosua Darko',
            payoutDate: 'Dec 1, 2026'),
      ],
    ),
    SusuGroup(
      id: 'gr2',
      name: 'Family Susu 2026',
      role: 'Admin',
      yourPosition: 1,
      poolAmount: 3600.00,
      nextPayout: 'Aug 15, 2026',
      contribution: 600.00,
      frequency: 'Weekly',
      collectedThisRound: 2400.00,
      inviteCode: 'KS-1190',
      youHavePaidThisRound: false,
      memberList: [
        GroupMember(
            id: 'gr2_m1',
            name: 'Kwame Mensah',
            phone: '054 *** 4567',
            position: 1,
            isYou: true),
        GroupMember(
            id: 'gr2_m2',
            name: 'Abena Mensah',
            phone: '024 *** 7788',
            position: 2,
            hasPaidThisRound: true),
        GroupMember(
            id: 'gr2_m3',
            name: 'Kofi Mensah',
            phone: '050 *** 1122',
            position: 3,
            hasPaidThisRound: true),
        GroupMember(
            id: 'gr2_m4',
            name: 'Adwoa Mensah',
            phone: '027 *** 4455',
            position: 4,
            hasPaidThisRound: true),
        GroupMember(
            id: 'gr2_m5',
            name: 'Uncle Joe',
            phone: '055 *** 9900',
            position: 5,
            hasPaidThisRound: true),
        GroupMember(
            id: 'gr2_m6',
            name: 'Auntie Grace',
            phone: '020 *** 3344',
            position: 6,
            hasPaidThisRound: false),
      ],
      messages: [
        GroupMessage(
          id: 'fmsg1',
          senderName: 'System',
          text:
              'You are #1 on the rotation — payout unlocks when the round is full.',
          time: '2d ago',
          isSystem: true,
        ),
        GroupMessage(
          id: 'fmsg2',
          senderName: 'Abena Mensah',
          text: 'Kwame, remember to pay before Friday.',
          time: 'Yesterday',
        ),
      ],
      rules: [
        'Weekly contribution of GHS 600 every Friday.',
        'Admin can invite or remove pending members.',
        'Payout follows rotation order.',
        'After receiving payout, keep contributing until the full rotation ends.',
        'Admin cannot remove members who have paid in or received payout mid-cycle.',
        'Family only — do not share the invite code publicly.',
      ],
      schedule: [
        RotationSlot(
            position: 1,
            memberName: 'Kwame Mensah (You)',
            payoutDate: 'Aug 15, 2026',
            isCurrent: true),
        RotationSlot(
            position: 2,
            memberName: 'Abena Mensah',
            payoutDate: 'Aug 22, 2026'),
        RotationSlot(
            position: 3,
            memberName: 'Kofi Mensah',
            payoutDate: 'Aug 29, 2026'),
        RotationSlot(
            position: 4,
            memberName: 'Adwoa Mensah',
            payoutDate: 'Sep 5, 2026'),
        RotationSlot(
            position: 5,
            memberName: 'Uncle Joe',
            payoutDate: 'Sep 12, 2026'),
        RotationSlot(
            position: 6,
            memberName: 'Auntie Grace',
            payoutDate: 'Sep 19, 2026'),
      ],
    ),
  ];

  SusuGroup? groupById(String id) {
    _ensureGroupModel();
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

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
    _ensureGroupModel();
    for (final group in _groups) {
      group.ensureCollections();
    }
    await simulateLoading();
  }

  Future<void> simulateLoading({bool fail = false}) async {
    isLoadingTransactions = true;
    isLoadingGoals = true;
    isLoadingPayments = true;
    isLoadingGroups = true;
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
      isLoadingGroups = false;
      notifyListeners();
      return;
    }

    isLoadingTransactions = false;
    isLoadingGoals = false;
    isLoadingPayments = false;
    isLoadingGroups = false;
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
    String lockType = 'strict',
    bool? isLocked,
    double autoSaveAmount = 25.00,
    bool isAutoSave = true,
  }) {
    final type = lockType == 'flexible' || lockType == 'strict'
        ? lockType
        : ((isLocked ?? true) ? 'strict' : 'flexible');
    _goals.insert(
      0,
      SusuGoal(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        targetAmount: targetAmount,
        currentSaved: 0.00,
        frequency: frequency,
        lockDate: type == 'flexible' && lockDate.trim().isEmpty
            ? 'Flexible'
            : lockDate,
        icon: _selectIconForTitle(title),
        lockType: type,
        autoSaveAmount: autoSaveAmount,
        isAutoSave: isAutoSave,
      ),
    );
    _pushNotification(
      title: 'New Goal Created',
      subtitle: type == 'strict'
          ? '“$title” is Strict — early withdrawals cost 15%.'
          : '“$title” is Flexible — withdraw anytime with no fee.',
      icon: Icons.flag_rounded,
      color: const Color(0xFF006E0A),
      bgColor: const Color(0xFFE8F8EA),
      route: '/goal_detail',
    );
    _persist();
    notifyListeners();
  }

  /// Withdraw from a savings goal into the wallet.
  /// Strict goals before unlock date: 15% platform penalty on the withdrawn amount.
  bool withdrawFromGoal(String goalId, double amount) {
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

    final goal = _goals[index];
    if (amount > goal.currentSaved) {
      lastError = 'Amount exceeds savings in this goal.';
      notifyListeners();
      return false;
    }

    final penalty = goal.earlyPenaltyFor(amount);
    final net = amount - penalty;
    goal.currentSaved = (goal.currentSaved - amount).clamp(0, double.infinity);
    _totalBalance += net;

    _transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Withdrew from ${goal.title}',
        date: 'Just now',
        amount: net,
        isDeposit: true,
        icon: Icons.north_east_rounded,
        method: 'Susu Wallet',
      ),
    );

    if (penalty > 0) {
      _transactions.insert(
        0,
        TransactionItem(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}_fee',
          title: 'Early withdrawal fee (15%) · ${goal.title}',
          date: 'Just now',
          amount: penalty,
          isDeposit: false,
          icon: Icons.gavel_rounded,
          method: 'Kwanpa Fee',
          category: 'Fees',
        ),
      );
      _pushNotification(
        title: 'Early Withdrawal Fee',
        subtitle:
            'GHS ${penalty.toStringAsFixed(2)} (15%) kept as platform fee. You received GHS ${net.toStringAsFixed(2)}.',
        icon: Icons.gavel_rounded,
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF3E0),
        route: '/transactions',
      );
    } else {
      _pushNotification(
        title: 'Goal Withdrawal',
        subtitle:
            'GHS ${net.toStringAsFixed(2)} moved from ${goal.title} to your wallet.',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF0066CC),
        bgColor: const Color(0xFFE6F4FF),
        route: '/transactions',
      );
    }

    lastError = null;
    _persist();
    notifyListeners();
    return true;
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
    _ensureGroupModel();
    final code = 'KS-${1000 + DateTime.now().millisecond % 9000}';
    final you = GroupMember(
      id: 'm_you_${DateTime.now().millisecondsSinceEpoch}',
      name: fullName,
      phone: phone,
      position: 1,
      isYou: true,
    );
    final placeholders = List.generate(
      (members - 1).clamp(0, 11),
      (i) => GroupMember(
        id: 'm_slot_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: 'Open slot ${i + 2}',
        phone: '',
        position: i + 2,
        status: 'pending',
      ),
    );
    final memberList = [you, ...placeholders];
    final schedule = _buildSchedule(
      members: memberList,
      frequency: frequency,
    );

    final newId = 'gr_${DateTime.now().millisecondsSinceEpoch}';
    _groups.insert(
      0,
      SusuGroup(
        id: newId,
        name: name,
        role: 'Admin',
        yourPosition: 1,
        poolAmount: 0,
        nextPayout: schedule.isNotEmpty ? schedule.first.payoutDate : 'TBD',
        contribution: contribution,
        frequency: frequency,
        collectedThisRound: 0,
        inviteCode: code,
        memberList: memberList,
        messages: [
          GroupMessage(
            id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
            senderName: 'System',
            text: 'Group created. Share invite code $code to add members.',
            time: 'Just now',
            isSystem: true,
          ),
        ],
        rules: [
          'Contribute GHS ${contribution.toStringAsFixed(0)} every $frequency cycle.',
          'Missed payments may skip your payout turn.',
          'Payouts follow the rotation schedule.',
          'After receiving payout, keep contributing until the full rotation ends.',
          'Admin cannot remove members who have paid in or received payout mid-cycle.',
          'Admin manages invites and pending members.',
        ],
        schedule: schedule,
      ),
    );
    _pushNotification(
      title: 'Group Created',
      subtitle: '“$name” is ready. Invite code: $code',
      icon: Icons.groups_rounded,
      color: const Color(0xFFE65100),
      bgColor: const Color(0xFFFFF3E0),
      route: '/group_detail',
      routeArgs: newId,
    );
    _persist();
    notifyListeners();
  }

  bool contributeToGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null) {
      lastError = 'Group not found.';
      notifyListeners();
      return false;
    }
    final pendingYou = group.memberList.any((m) => m.isYou && m.status == 'pending');
    if (pendingYou) {
      lastError = 'Your join request is still pending admin approval.';
      notifyListeners();
      return false;
    }
    if (group.youHavePaidThisRound) {
      lastError = 'You already contributed this round.';
      notifyListeners();
      return false;
    }
    if (_totalBalance < group.contribution) {
      lastError = 'Insufficient wallet balance.';
      notifyListeners();
      return false;
    }

    _totalBalance -= group.contribution;
    group.collectedThisRound += group.contribution;
    group.poolAmount += group.contribution;
    group.youHavePaidThisRound = true;
    for (final m in group.memberList) {
      if (m.isYou) {
        m.hasPaidThisRound = true;
        m.cycleContributions += 1;
      }
    }

    _transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Group contribution · ${group.name}',
        date: 'Just now',
        amount: group.contribution,
        isDeposit: false,
        icon: Icons.groups_rounded,
        method: 'Susu Wallet',
      ),
    );
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text:
            'You contributed GHS ${group.contribution.toStringAsFixed(0)} to this round.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    group.contributionHistory.insert(
      0,
      GroupLedgerEntry(
        id: 'led_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Round contribution',
        memberName: fullName,
        amount: group.contribution,
        date: 'Just now',
        type: 'contribution',
      ),
    );
    _pushNotification(
      title: 'Group Contribution Sent',
      subtitle:
          'GHS ${group.contribution.toStringAsFixed(0)} paid to ${group.name}.',
      icon: Icons.groups_rounded,
      color: const Color(0xFFE65100),
      bgColor: const Color(0xFFFFF3E0),
      route: '/group_detail',
      routeArgs: group.id,
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool claimGroupPayout(String groupId) {
    final group = groupById(groupId);
    if (group == null) {
      lastError = 'Group not found.';
      notifyListeners();
      return false;
    }
    if (!group.canClaimPayout) {
      lastError = group.isYourPayoutTurn
          ? 'Round is not fully funded yet.'
          : 'It is not your turn to claim payout.';
      notifyListeners();
      return false;
    }

    final payout = group.collectedThisRound;
    _totalBalance += payout;
    group.poolAmount = (group.poolAmount - payout).clamp(0, double.infinity);
    group.collectedThisRound = 0;
    group.youHavePaidThisRound = false;
    for (final m in group.memberList) {
      m.hasPaidThisRound = false;
      m.skippedThisCycle = false;
      if (m.isYou) m.hasReceivedPayout = true;
    }

    final currentIndex = group.schedule.indexWhere((s) => s.isCurrent);
    if (currentIndex != -1) {
      group.schedule[currentIndex].isPaidOut = true;
      group.schedule[currentIndex].isCurrent = false;
      if (currentIndex + 1 < group.schedule.length) {
        group.schedule[currentIndex + 1].isCurrent = true;
        group.nextPayout = group.schedule[currentIndex + 1].payoutDate;
        group.yourPosition = group.schedule
            .firstWhere((s) => s.memberName.contains('(You)'),
                orElse: () => group.schedule.first)
            .position;
      }
    }

    if (group.isCycleComplete) {
      _resetGroupCycle(group);
    }

    _transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Group payout · ${group.name}',
        date: 'Just now',
        amount: payout,
        isDeposit: true,
        icon: Icons.payments_rounded,
        method: 'Group Susu',
      ),
    );
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: 'You claimed payout of GHS ${payout.toStringAsFixed(0)}.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    group.payoutHistory.insert(
      0,
      GroupLedgerEntry(
        id: 'led_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Rotation payout',
        memberName: fullName,
        amount: payout,
        date: 'Just now',
        type: 'payout',
      ),
    );
    _pushNotification(
      title: 'Payout Received',
      subtitle: 'GHS ${payout.toStringAsFixed(0)} from ${group.name}.',
      icon: Icons.payments_rounded,
      color: const Color(0xFF006E0A),
      bgColor: const Color(0xFFE8F8EA),
      route: '/group_detail',
      routeArgs: group.id,
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool inviteMember(String groupId, String name, String phone) {
    final group = groupById(groupId);
    if (group == null) {
      lastError = 'Group not found.';
      notifyListeners();
      return false;
    }
    if (name.trim().isEmpty) {
      lastError = 'Enter a member name.';
      notifyListeners();
      return false;
    }

    final nextPos = group.memberList.isEmpty
        ? 1
        : group.memberList.map((m) => m.position).reduce((a, b) => a > b ? a : b) +
            1;

    group.memberList.add(
      GroupMember(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        phone: phone.trim().isEmpty ? 'Pending' : phone.trim(),
        position: nextPos,
        status: 'pending',
      ),
    );
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: 'Invite sent to ${name.trim()}.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool acceptPendingMember(String groupId, String memberId) {
    final group = groupById(groupId);
    if (group == null) return false;
    final member = group.memberList.where((m) => m.id == memberId).toList();
    if (member.isEmpty) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can accept members.';
      notifyListeners();
      return false;
    }
    member.first.status = 'active';
    if (member.first.isYou) {
      group.yourPosition = member.first.position;
    }
    group.schedule = _buildSchedule(
      members: group.memberList,
      frequency: group.frequency,
    );
    if (group.schedule.isNotEmpty) {
      group.nextPayout = group.schedule
          .firstWhere((s) => s.isCurrent, orElse: () => group.schedule.first)
          .payoutDate;
    }
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: '${member.first.name} was accepted into the group.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    _persist();
    notifyListeners();
    return true;
  }

  bool removeMember(String groupId, String memberId) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can remove members.';
      notifyListeners();
      return false;
    }
    final member = group.memberList.where((m) => m.id == memberId).toList();
    if (member.isEmpty || member.first.isYou) return false;

    final block = group.exitBlockReason(member.first);
    if (block != null) {
      lastError = block;
      notifyListeners();
      return false;
    }

    final name = member.first.name;
    group.memberList.removeWhere((m) => m.id == memberId);
    group.schedule.removeWhere((s) => s.memberName.startsWith(name));
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: '$name was removed from the group.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool joinGroupByCode(String code) {
    _ensureGroupModel();
    final cleaned = code.trim().toUpperCase();
    if (cleaned.isEmpty) {
      lastError = 'Enter an invite code.';
      notifyListeners();
      return false;
    }
    SusuGroup? group;
    try {
      group = _groups.firstWhere(
        (g) => g.inviteCode.toUpperCase() == cleaned,
      );
    } catch (_) {
      lastError = 'No group found for that invite code.';
      notifyListeners();
      return false;
    }

    if (group.isArchived) {
      lastError = 'This group is archived and not accepting members.';
      notifyListeners();
      return false;
    }

    if (group.memberList.any((m) => m.isYou)) {
      lastError = 'You are already in this group.';
      notifyListeners();
      return false;
    }

    final nextPos = group.memberList.isEmpty
        ? 1
        : group.memberList.map((m) => m.position).reduce((a, b) => a > b ? a : b) +
            1;
    // Join requests stay pending until the group admin accepts.
    group.memberList.add(
      GroupMember(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        name: fullName,
        phone: phone,
        position: nextPos,
        isYou: true,
        status: 'pending',
      ),
    );
    group.role = 'Member';
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: '$fullName requested to join. Waiting for admin approval.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    group.unreadChatCount += 1;
    _pushNotification(
      title: 'Join request sent',
      subtitle: 'Waiting for the admin of ${group.name} to accept you.',
      icon: Icons.hourglass_top_rounded,
      color: const Color(0xFFE65100),
      bgColor: const Color(0xFFFFF3E0),
      route: '/group_detail',
      routeArgs: group.id,
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  void sendGroupMessage(String groupId, String text) {
    final group = groupById(groupId);
    if (group == null || text.trim().isEmpty) return;
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'You',
        text: text.trim(),
        time: 'Just now',
        isYou: true,
      ),
    );
    group.unreadChatCount = 0;
    _persist();
    notifyListeners();
  }

  void markGroupChatRead(String groupId) {
    final group = groupById(groupId);
    if (group == null) return;
    group.unreadChatCount = 0;
    notifyListeners();
  }

  void deleteGroupMessage(String groupId, String messageId) {
    final group = groupById(groupId);
    if (group == null) return;
    group.messages.removeWhere((m) => m.id == messageId && m.isYou);
    _persist();
    notifyListeners();
  }

  void updateGroupRules(String groupId, List<String> rules) {
    final group = groupById(groupId);
    if (group == null) return;
    group.rules
      ..clear()
      ..addAll(rules.where((r) => r.trim().isNotEmpty));
    _persist();
    notifyListeners();
  }

  bool editGroup({
    required String groupId,
    String? name,
    double? contribution,
    String? frequency,
    List<String>? rules,
  }) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can edit this group.';
      notifyListeners();
      return false;
    }
    if (name != null && name.trim().isNotEmpty) group.name = name.trim();
    if (contribution != null && contribution > 0) {
      group.contribution = contribution;
    }
    if (frequency != null) {
      group.frequency = frequency;
      group.schedule = _buildSchedule(
        members: group.memberList,
        frequency: frequency,
      );
      if (group.schedule.isNotEmpty) {
        group.nextPayout = group.schedule.firstWhere(
          (s) => s.isCurrent,
          orElse: () => group.schedule.first,
        ).payoutDate;
      }
    }
    if (rules != null) {
      group.rules
        ..clear()
        ..addAll(rules.where((r) => r.trim().isNotEmpty));
    }
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: 'Group settings were updated by admin.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool leaveGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null) return false;

    GroupMember? you;
    try {
      you = group.memberList.firstWhere((m) => m.isYou);
    } catch (_) {
      you = null;
    }
    if (you != null) {
      final block = group.exitBlockReason(you);
      if (block != null) {
        lastError = block;
        notifyListeners();
        return false;
      }
    }

    if (group.role == 'Admin') {
      final others = group.memberList
          .where((m) => !m.isYou && m.status == 'active')
          .length;
      if (others > 0) {
        lastError =
            'As admin, dissolve the group or remove other members first.';
        notifyListeners();
        return false;
      }
    }
    final name = group.name;
    _groups.removeWhere((g) => g.id == groupId);
    _pushNotification(
      title: 'Left Group',
      subtitle: 'You left $name.',
      icon: Icons.logout_rounded,
      color: const Color(0xFF0066CC),
      bgColor: const Color(0xFFE6F4FF),
      route: '/groups',
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool dissolveGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can dissolve a group.';
      notifyListeners();
      return false;
    }
    if (group.collectedThisRound > 0 ||
        (!group.isCycleComplete &&
            group.memberList.any((m) =>
                m.hasReceivedPayout ||
                m.cycleContributions > 0 ||
                m.hasPaidThisRound))) {
      lastError =
          'Cannot dissolve while members have paid in or received payouts in an active cycle.';
      notifyListeners();
      return false;
    }
    final name = group.name;
    _groups.removeWhere((g) => g.id == groupId);
    _pushNotification(
      title: 'Group Dissolved',
      subtitle: '“$name” has been closed.',
      icon: Icons.delete_forever_rounded,
      color: const Color(0xFFD32F2F),
      bgColor: const Color(0xFFFFEBEE),
      route: '/groups',
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool archiveGroup(String groupId, {bool archived = true}) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can archive a group.';
      notifyListeners();
      return false;
    }
    group.isArchived = archived;
    _persist();
    notifyListeners();
    return true;
  }

  bool declinePendingMember(String groupId, String memberId) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can decline invites.';
      notifyListeners();
      return false;
    }
    final member = group.memberList.where((m) => m.id == memberId).toList();
    if (member.isEmpty) return false;
    final name = member.first.name;
    group.memberList.removeWhere((m) => m.id == memberId);
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: 'Invite for $name was declined.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    _persist();
    notifyListeners();
    return true;
  }

  bool skipMemberTurn(String groupId, String memberId) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can skip a member.';
      notifyListeners();
      return false;
    }
    final matches = group.memberList.where((m) => m.id == memberId).toList();
    if (matches.isEmpty) return false;
    final member = matches.first;
    member.skippedThisCycle = true;
    member.hasPaidThisRound = false;
    group.contributionHistory.insert(
      0,
      GroupLedgerEntry(
        id: 'led_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Skipped this round',
        memberName: member.name,
        amount: 0,
        date: 'Just now',
        type: 'skip',
      ),
    );
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: '${member.name} was marked skipped for this round.',
        time: 'Just now',
        isSystem: true,
      ),
    );
    lastError = null;
    _persist();
    notifyListeners();
    return true;
  }

  bool reorderSchedule(String groupId, int oldIndex, int newIndex) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can reorder the rotation.';
      notifyListeners();
      return false;
    }
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= group.schedule.length ||
        newIndex >= group.schedule.length) {
      return false;
    }
    final item = group.schedule.removeAt(oldIndex);
    group.schedule.insert(newIndex, item);
    for (var i = 0; i < group.schedule.length; i++) {
      group.schedule[i].isCurrent = i == 0 && !group.schedule[i].isPaidOut;
      // Rebuild positions visually via name order; keep payout dates.
    }
    // Ensure exactly one current among unpaid.
    final unpaid = group.schedule.where((s) => !s.isPaidOut).toList();
    for (final s in group.schedule) {
      s.isCurrent = false;
    }
    if (unpaid.isNotEmpty) {
      unpaid.first.isCurrent = true;
      group.nextPayout = unpaid.first.payoutDate;
    }
    _persist();
    notifyListeners();
    return true;
  }

  bool rebuildScheduleDates(String groupId, DateTime startDate) {
    final group = groupById(groupId);
    if (group == null) return false;
    if (group.role != 'Admin') {
      lastError = 'Only admins can edit the schedule.';
      notifyListeners();
      return false;
    }
    group.schedule = _buildSchedule(
      members: group.memberList,
      frequency: group.frequency,
      start: startDate,
      existingNames: group.schedule.map((s) => s.memberName).toList(),
    );
    if (group.schedule.isNotEmpty) {
      group.nextPayout = group.schedule.first.payoutDate;
    }
    _persist();
    notifyListeners();
    return true;
  }

  List<RotationSlot> _buildSchedule({
    required List<GroupMember> members,
    required String frequency,
    DateTime? start,
    List<String>? existingNames,
  }) {
    final active = members
        .where((m) => m.status == 'active' || m.isYou)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final base = start ?? DateTime.now().add(const Duration(days: 7));
    final step = switch (frequency) {
      'Daily' => const Duration(days: 1),
      'Monthly' => const Duration(days: 30),
      _ => const Duration(days: 7),
    };
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return List.generate(active.length, (i) {
      final m = active[i];
      final d = base.add(step * i);
      final name = existingNames != null && i < existingNames.length
          ? existingNames[i]
          : (m.isYou ? '${m.name} (You)' : m.name);
      return RotationSlot(
        position: i + 1,
        memberName: name,
        payoutDate: '${months[d.month - 1]} ${d.day}, ${d.year}',
        isCurrent: i == 0,
      );
    });
  }

  void _resetGroupCycle(SusuGroup group) {
    for (final m in group.memberList) {
      m.hasReceivedPayout = false;
      m.cycleContributions = 0;
      m.hasPaidThisRound = false;
      m.skippedThisCycle = false;
    }
    group.youHavePaidThisRound = false;
    group.collectedThisRound = 0;
    // Start a fresh rotation using the same member order.
    group.schedule = _buildSchedule(
      members: group.memberList,
      frequency: group.frequency,
    );
    if (group.schedule.isNotEmpty) {
      group.nextPayout = group.schedule.first.payoutDate;
    }
    group.messages.insert(
      0,
      GroupMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'System',
        text: 'Cycle complete. A new rotation has started.',
        time: 'Just now',
        isSystem: true,
      ),
    );
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
    Object? routeArgs,
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
        routeArgs: routeArgs,
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
      // Drop older schema keys that can leave incomplete group objects.
      await prefs.remove('kwanpa_susu_state_v1');
      await prefs.remove('kwanpa_susu_state_v2');
      await prefs.remove('kwanpa_susu_state_v3');
      await prefs.remove('kwanpa_susu_state_v4');
      await prefs.remove('kwanpa_susu_state_v5');

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
                .map((e) => SusuGoal.fromJson(Map<String, dynamic>.from(e as Map))),
          );
      }
      if (data['transactions'] is List) {
        _transactions
          ..clear()
          ..addAll(
            (data['transactions'] as List).map(
              (e) => TransactionItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
      }
      if (data['budgetCategories'] is List) {
        _budgetCategories
          ..clear()
          ..addAll(
            (data['budgetCategories'] as List).map(
              (e) => BudgetCategory.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
      }
      if (data['paymentMethods'] is List) {
        _paymentMethods
          ..clear()
          ..addAll(
            (data['paymentMethods'] as List).map(
              (e) => PaymentMethod.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
      }
      if (data['notifications'] is List) {
        _notifications
          ..clear()
          ..addAll(
            (data['notifications'] as List).map(
              (e) => AppNotification.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
      }
      if (data['groups'] is List) {
        final loaded = <SusuGroup>[];
        for (final e in data['groups'] as List) {
          try {
            final group = SusuGroup.fromJson(
              Map<String, dynamic>.from(e as Map),
            );
            group.ensureCollections();
            // Skip legacy/incomplete groups that have no members.
            if (group.memberList.isEmpty && group.inviteCode.isEmpty) {
              continue;
            }
            loaded.add(group);
          } catch (_) {
            // Ignore corrupt group entries.
          }
        }
        if (loaded.isNotEmpty) {
          _groups
            ..clear()
            ..addAll(loaded);
          _activeGroupModelVersion = _groupModelVersion;
        }
      }
      notifyListeners();
    } catch (_) {
      // Ignore corrupt storage and keep seeded defaults.
    }
  }
}
