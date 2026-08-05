import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';

class BudgetScreen extends StatelessWidget {
  final bool embedded;

  const BudgetScreen({super.key, this.embedded = false});

  void _showIncomeDialog(BuildContext context, AppState state) {
    final controller =
        TextEditingController(text: state.monthlyIncome.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Monthly income',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Income (GHS)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount <= 0) return;
              AppState().setMonthlyIncome(amount);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantGreen),
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.darkGreenAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showCashExpenseDialog(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final cats = AppState().budgetCategories;
    String category = cats.isNotEmpty ? cats.first.name : 'Food & Groceries';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Log cash expense',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'For market, trotro, chop bar — money that didn’t leave the wallet.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (GHS)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: cats
                    .map((c) =>
                        DropdownMenuItem(value: c.name, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setModal(() => category = v ?? category),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g., Kejetia market',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vibrantGreen),
              child: const Text('Continue',
                  style: TextStyle(
                      color: AppColors.darkGreenAccent,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final warning = AppState().budgetImpactWarning(category, amount);
    if (warning != null) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Budget warning'),
          content: Text(warning),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Log anyway')),
          ],
        ),
      );
      if (go != true || !context.mounted) return;
    }

    final ok = AppState().addCashExpense(
      amount: amount,
      category: category,
      note: noteCtrl.text,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Cash expense logged'
            : (AppState().lastError ?? 'Could not log expense')),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {BudgetCategory? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final amountController = TextEditingController(
      text: existing != null ? existing.total.toStringAsFixed(0) : '',
    );
    var isProtected = existing?.isProtected ?? false;
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(isEdit ? Icons.edit_rounded : Icons.add_chart_rounded,
                  color: AppColors.forestGreen),
              const SizedBox(width: 10),
              Text(isEdit ? 'Edit Category' : 'Add Budget Category',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.darkGreen)),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monthly limit (GHS)',
                  hintText: 'e.g., 500',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Protect this category',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Stronger warning before overspending (good for Susu).',
                  style: TextStyle(fontSize: 12),
                ),
                value: isProtected,
                activeThumbColor: AppColors.darkGreen,
                onChanged: (v) => setModal(() => isProtected = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text.trim());
                if (name.isEmpty || amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Enter a name and valid limit')),
                  );
                  return;
                }
                if (isEdit) {
                  AppState().updateBudgetCategory(
                    existing.id,
                    name: name,
                    total: amount,
                    isProtected: isProtected,
                  );
                } else {
                  AppState().addBudgetCategory(
                    name,
                    amount,
                    isProtected: isProtected,
                  );
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEdit ? 'Save' : 'Add Category',
                  style: const TextStyle(
                      color: AppColors.darkGreenAccent,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BudgetCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Remove “${category.name}” from your budget?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              AppState().removeBudgetCategory(category.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _carryMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Carry leftovers',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen)),
              const SizedBox(height: 6),
              Text(
                'Unused limits this month: GHS ${AppState().totalLeftoverLimits.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.savings_rounded,
                    color: AppColors.forestGreen),
                title: const Text('Move into Susu & Savings'),
                subtitle: const Text('Boost your savings budget cap'),
                onTap: () {
                  final ok = AppState().carryLeftoversToSavings();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Leftovers moved to savings'
                          : (AppState().lastError ?? 'Nothing to move')),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.next_plan_rounded,
                    color: Color(0xFF0066CC)),
                title: const Text('Carry to next month'),
                subtitle: const Text('Add unused room when you tap New month'),
                onTap: () {
                  final ok = AppState().carryLeftoversToNextMonth();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Queued for next month'
                          : (AppState().lastError ?? 'Nothing to carry')),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final overBudget = state.isOverBudget;
        final usedPct = (state.budgetUsedRatio * 100).clamp(0, 999);
        final goalMsg = state.susuGoalLinkMessage;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budgeting',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track spending from wallet and cash.',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => AppState().startNewBudgetMonth(),
                    child: const Text('New month',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Period · ${state.budgetPeriodLabel}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _periodChip(
                          'Month',
                          selected: !state.budgetShowWeekly,
                          onTap: () => AppState().setBudgetShowWeekly(false),
                        ),
                        _periodChip(
                          'Week',
                          selected: state.budgetShowWeekly,
                          onTap: () => AppState().setBudgetShowWeekly(true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.forestGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.budgetTipOfTheWeek,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkGreen,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (goalMsg != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_rounded,
                          color: Color(0xFFF57F17), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          goalMsg,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFF57F17),
                            height: 1.35,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/create_goal'),
                        child: const Text('Goals',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Log cash'),
                    onPressed: () => _showCashExpenseDialog(context),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Carry leftovers'),
                    onPressed: () => _carryMenu(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: overBudget
                        ? const Color(0xFFD32F2F).withValues(alpha: 0.35)
                        : AppColors.darkGreen.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.budgetShowWeekly
                              ? 'This Week'
                              : 'Monthly Overview',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: overBudget
                                ? const Color(0xFFFFCDD2)
                                : const Color(0xFFBCEDD7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            overBudget ? 'Over Budget' : 'On Track',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: overBudget
                                  ? const Color(0xFFC62828)
                                  : AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _showIncomeDialog(context, state),
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text('Income',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary)),
                                    SizedBox(width: 4),
                                    Icon(Icons.edit_outlined,
                                        size: 14,
                                        color: AppColors.textSecondary),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'GHS ${state.monthlyIncome.toStringAsFixed(0)}',
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
                                const Text('Total Expenses',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  'GHS ${state.totalExpenses.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: overBudget
                                        ? const Color(0xFFD32F2F)
                                        : AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Allocated: GHS ${state.totalAllocated.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                        Text(
                          '${usedPct.toStringAsFixed(0)}% of income',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: overBudget
                                ? const Color(0xFFD32F2F)
                                : AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        overBudget
                            ? 'Over by GHS ${(-state.remainingBudget).toStringAsFixed(0)}'
                            : 'GHS ${state.remainingBudget.toStringAsFixed(0)} left',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: overBudget
                              ? const Color(0xFFD32F2F)
                              : AppColors.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: state.budgetUsedPercent,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          overBudget
                              ? const Color(0xFFD32F2F)
                              : AppColors.vibrantGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.budgetShowWeekly
                        ? 'Categories (weekly)'
                        : 'Categories',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.forestGreen),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.budgetCategories.isEmpty)
                EmptyState(
                  icon: Icons.pie_chart_outline_rounded,
                  title: 'No budget categories',
                  message: 'Add categories to track where your money goes.',
                  actionLabel: 'Add Category',
                  onAction: () => _showCategoryDialog(context),
                )
              else
                ...state.budgetCategories.map((c) {
                  final spent = state.displaySpentFor(c);
                  final limit = state.displayLimitFor(c);
                  final progress =
                      limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
                  final over = spent > limit;
                  final near = !over && progress >= 0.8;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(c.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        _confirmDelete(context, c);
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Color(0xFFD32F2F)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () =>
                              _showCategoryDialog(context, existing: c),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: over
                                    ? const Color(0xFFD32F2F)
                                        .withValues(alpha: 0.4)
                                    : AppColors.notchColor
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: c.color.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child:
                                          Icon(c.icon, color: c.color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  c.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.darkGreen,
                                                  ),
                                                ),
                                              ),
                                              if (c.isProtected) ...[
                                                const SizedBox(width: 6),
                                                const Icon(Icons.shield_rounded,
                                                    size: 14,
                                                    color: AppColors.forestGreen),
                                              ],
                                            ],
                                          ),
                                          if (over || near)
                                            Text(
                                              over
                                                  ? 'Over limit'
                                                  : 'Near limit (80%+)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: over
                                                    ? const Color(0xFFD32F2F)
                                                    : const Color(0xFFE65100),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'GHS ${spent.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: over
                                            ? const Color(0xFFD32F2F)
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 7,
                                    backgroundColor: const Color(0xFFEEEEEE),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      over ? const Color(0xFFD32F2F) : c.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkGreen, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _periodChip(String label,
      {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppColors.darkGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
