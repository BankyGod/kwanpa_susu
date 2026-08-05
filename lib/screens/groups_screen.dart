import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/kyc_gate.dart';

enum _GroupFilter { active, admin, archived }

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  _GroupFilter _filter = _GroupFilter.active;

  void _showExplainer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'How Group Susu works',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            SizedBox(height: 12),
            Text('1. Create or join a trusted circle.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
            SizedBox(height: 6),
            Text('2. Everyone contributes each cycle.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
            SizedBox(height: 6),
            Text('3. One member receives the full pot per turn.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
            SizedBox(height: 6),
            Text('4. Rotation continues until everyone has been paid.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupSheet() async {
    final allowed = await ensureKycVerified(
      context,
      actionLabel: 'create a Group Susu',
    );
    if (!allowed || !mounted) return;

    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '100.00');
    String frequency = 'Weekly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  const Text(
                    'Create Group Susu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Contribution (GHS)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: frequency,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                          value: 'Monthly', child: Text('Monthly')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => frequency = v);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final amount =
                            double.tryParse(amountController.text.trim());
                        if (name.isEmpty || amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Enter a valid name and amount')),
                          );
                          return;
                        }
                        AppState().addGroup(
                          name: name,
                          contribution: amount,
                          frequency: frequency,
                        );
                        Navigator.pop(ctx);
                        final created = AppState().groups.first;
                        Navigator.of(context).pushNamed(
                          '/group_detail',
                          arguments: created.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Create Group',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreenAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showJoinSheet() async {
    final allowed = await ensureKycVerified(
      context,
      actionLabel: 'join a Group Susu',
    );
    if (!allowed || !mounted) return;

    final codeController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
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
              const Text(
                'Join with Invite Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Invite code',
                  hintText: 'KS-4821',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final ok =
                        AppState().joinGroupByCode(codeController.text);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Join request sent — waiting for admin approval'
                              : (AppState().lastError ?? 'Could not join'),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Join Group',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreenAccent,
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

  List<SusuGroup> _filtered(List<SusuGroup> all) {
    switch (_filter) {
      case _GroupFilter.admin:
        return all
            .where((g) => !g.isArchived && g.role == 'Admin')
            .toList();
      case _GroupFilter.archived:
        return all.where((g) => g.isArchived).toList();
      case _GroupFilter.active:
        return all.where((g) => !g.isArchived).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Group Susu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'How it works',
            onPressed: _showExplainer,
            icon: const Icon(Icons.info_outline_rounded,
                color: AppColors.darkGreen),
          ),
          TextButton(
            onPressed: _showJoinSheet,
            child: const Text(
              'Join',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.forestGreen,
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppState(),
        builder: (context, _) {
          final state = AppState();
          if (state.hasLoadError) {
            return ErrorState(
              message: state.lastError ?? 'Could not load groups.',
              onRetry: state.retryLoad,
            );
          }
          if (state.isLoadingGroups) {
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) => const ShimmerCardPlaceholder(height: 120),
            );
          }

          final groups = _filtered(state.groups);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    _filterChip('Active', _GroupFilter.active),
                    const SizedBox(width: 8),
                    _filterChip('Admin', _GroupFilter.admin),
                    const SizedBox(width: 8),
                    _filterChip('Archived', _GroupFilter.archived),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PrimaryButton(
                    onPressed: _showCreateGroupSheet,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_add_rounded,
                            color: AppColors.darkGreenAccent),
                        SizedBox(width: 8),
                        Text(
                          'Create Group',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreenAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: groups.isEmpty
                    ? EmptyState(
                        icon: Icons.groups_outlined,
                        title: _filter == _GroupFilter.archived
                            ? 'No archived groups'
                            : 'No groups yet',
                        message: _filter == _GroupFilter.archived
                            ? 'Archived groups will appear here.'
                            : 'Start a group susu or join one with an invite code.',
                        actionLabel: 'Create Group',
                        onAction: _showCreateGroupSheet,
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: groups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final g = groups[index];
                          g.ensureCollections();
                          return _groupCard(g);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, _GroupFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.vibrantGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.vibrantGreen
                : AppColors.notchColor.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? AppColors.darkGreenAccent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _groupCard(SusuGroup g) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).pushNamed(
        '/group_detail',
        arguments: g.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.notchColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups_rounded,
                      color: Color(0xFFE65100)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      Text(
                        '${g.role} · ${g.members} members · ${g.inviteCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (g.pendingInvites > 0)
                  _badge('${g.pendingInvites} pending', const Color(0xFFFFF3E0),
                      const Color(0xFFE65100)),
                if (g.unpaidActiveCount > 0)
                  _badge('${g.unpaidActiveCount} unpaid', const Color(0xFFFFEBEE),
                      const Color(0xFFD32F2F)),
                if (g.unreadChatCount > 0)
                  _badge('${g.unreadChatCount} chat', const Color(0xFFE8F8EA),
                      AppColors.forestGreen),
                if (g.isArchived)
                  _badge('Archived', const Color(0xFFF5F5F5),
                      AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: g.roundProgress,
                minHeight: 6,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('Pool', 'GHS ${g.poolAmount.toStringAsFixed(0)}'),
                _stat('Your turn', '#${g.yourPosition}'),
                _stat('Next', g.nextPayout),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
      ],
    );
  }
}
