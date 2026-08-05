import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/kyc_gate.dart';

class GroupDetailScreen extends StatefulWidget {
  final String? groupId;

  const GroupDetailScreen({super.key, this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _chatController = TextEditingController();
  String _memberQuery = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() {
      if (_tabs.index == 3) {
        final id = _resolvedId;
        if (id != null) AppState().markGroupChatRead(id);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _chatController.dispose();
    super.dispose();
  }

  String? get _resolvedId {
    final arg = widget.groupId ??
        ModalRoute.of(context)?.settings.arguments as String?;
    if (arg != null) return arg;
    final groups = AppState().groups;
    return groups.isEmpty ? null : groups.first.id;
  }

  void _toast(String msg, {bool ok = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? AppColors.forestGreen : Colors.redAccent,
      ),
    );
  }

  Future<void> _confirmContribute(SusuGroup group) async {
    final allowed = await ensureKycVerified(
      context,
      actionLabel: 'contribute to Group Susu',
    );
    if (!allowed || !mounted) return;

    if (group.youHavePaidThisRound) {
      _toast(group.contributeBlockReason, ok: false);
      return;
    }
    final confirmed = await showModalBottomSheet<bool>(
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
          children: [
            const Text('Confirm contribution',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
            const SizedBox(height: 10),
            Text(
              'Pay GHS ${group.contribution.toStringAsFixed(2)} from your wallet into ${group.name}?',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Wallet balance: GHS ${AppState().totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (AppState().twoFactorEnabled) ...[
              const SizedBox(height: 8),
              const Text(
                '2FA prompt enabled — treat this as your confirmation step.',
                style: TextStyle(fontSize: 12, color: AppColors.forestGreen),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantGreen,
                      foregroundColor: AppColors.darkGreenAccent,
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final ok = AppState().contributeToGroup(group.id);
    _toast(
      ok
          ? 'Contributed GHS ${group.contribution.toStringAsFixed(0)}'
          : (AppState().lastError ?? 'Contribution failed'),
      ok: ok,
    );
  }

  Future<void> _confirmPayout(SusuGroup group) async {
    final allowed = await ensureKycVerified(
      context,
      actionLabel: 'claim a Group Susu payout',
    );
    if (!allowed || !mounted) return;

    if (!group.canClaimPayout) {
      _toast(group.payoutBlockReason, ok: false);
      return;
    }
    final amount = group.collectedThisRound;
    final confirmed = await showModalBottomSheet<bool>(
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
          children: [
            const Text('Confirm payout',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
            const SizedBox(height: 10),
            Text(
              'Claim GHS ${amount.toStringAsFixed(2)} into your wallet? This advances the rotation.',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vibrantGreen,
                      foregroundColor: AppColors.darkGreenAccent,
                    ),
                    child: const Text('Claim'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final ok = AppState().claimGroupPayout(group.id);
    _toast(ok ? 'Payout claimed' : (AppState().lastError ?? 'Payout failed'),
        ok: ok);
  }

  void _shareInvite(SusuGroup group) {
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
          children: [
            const Text('Share invite',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
            const SizedBox(height: 16),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.notchColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_2_rounded,
                      size: 64, color: AppColors.darkGreen),
                  const SizedBox(height: 8),
                  Text(group.inviteCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Join my Kwanpa Susu group “${group.name}” with code ${group.inviteCode}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text:
                        'Join my Kwanpa Susu group “${group.name}” with code ${group.inviteCode}',
                  ));
                  Navigator.pop(ctx);
                  _toast('Invite message copied');
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy invite message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vibrantGreen,
                  foregroundColor: AppColors.darkGreenAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editGroup(SusuGroup group) {
    final nameCtrl = TextEditingController(text: group.name);
    final amountCtrl =
        TextEditingController(text: group.contribution.toStringAsFixed(2));
    final rulesCtrl = TextEditingController(text: group.rules.join('\n'));
    var frequency = group.frequency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit group',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Contribution (GHS)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      if (v != null) setModal(() => frequency = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: rulesCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Rules (one per line)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final ok = AppState().editGroup(
                          groupId: group.id,
                          name: nameCtrl.text,
                          contribution: double.tryParse(amountCtrl.text),
                          frequency: frequency,
                          rules: rulesCtrl.text
                              .split('\n')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                        );
                        Navigator.pop(ctx);
                        _toast(
                          ok
                              ? 'Group updated'
                              : (AppState().lastError ?? 'Update failed'),
                          ok: ok,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantGreen,
                        foregroundColor: AppColors.darkGreenAccent,
                      ),
                      child: const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showHistories(SusuGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, controller) {
            final entries = [
              ...group.payoutHistory,
              ...group.contributionHistory,
            ];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Group history',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: entries.isEmpty
                        ? const EmptyState(
                            icon: Icons.history_rounded,
                            title: 'No history yet',
                            message:
                                'Contributions and payouts will appear here.',
                          )
                        : ListView.separated(
                            controller: controller,
                            itemCount: entries.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final e = entries[i];
                              final isPay = e.type == 'payout';
                              final isSkip = e.type == 'skip';
                              return ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: AppColors.notchColor
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                leading: Icon(
                                  isPay
                                      ? Icons.payments_rounded
                                      : isSkip
                                          ? Icons.skip_next_rounded
                                          : Icons.south_west_rounded,
                                  color: isPay
                                      ? AppColors.forestGreen
                                      : isSkip
                                          ? const Color(0xFFE65100)
                                          : AppColors.darkGreen,
                                ),
                                title: Text(e.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGreen)),
                                subtitle: Text(
                                    '${e.memberName} · ${e.date}',
                                    style: const TextStyle(fontSize: 12)),
                                trailing: Text(
                                  isSkip
                                      ? 'Skipped'
                                      : 'GHS ${e.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
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

  void _memberSheet(SusuGroup group, GroupMember m) {
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
          children: [
            Text(m.isYou ? '${m.name} (You)' : m.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
            const SizedBox(height: 6),
            Text(
              m.status == 'pending'
                  ? 'Pending invite · ${m.phone}'
                  : '#${m.position} · ${m.phone}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              m.skippedThisCycle
                  ? 'Status: Skipped this round'
                  : m.hasPaidThisRound
                      ? 'Status: Paid this round'
                      : 'Status: Unpaid this round',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (group.role == 'Admin' && !m.isYou) ...[
              if (m.status == 'pending') ...[
                ListTile(
                  leading: const Icon(Icons.check_circle,
                      color: AppColors.forestGreen),
                  title: const Text('Accept invite'),
                  onTap: () {
                    AppState().acceptPendingMember(group.id, m.id);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined,
                      color: Color(0xFFD32F2F)),
                  title: const Text('Decline invite'),
                  onTap: () {
                    AppState().declinePendingMember(group.id, m.id);
                    Navigator.pop(ctx);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.skip_next_rounded,
                      color: Color(0xFFE65100)),
                  title: const Text('Skip this round'),
                  onTap: () {
                    final ok = AppState().skipMemberTurn(group.id, m.id);
                    Navigator.pop(ctx);
                    _toast(
                      ok
                          ? '${m.name} skipped'
                          : (AppState().lastError ?? 'Failed'),
                      ok: ok,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.person_remove_outlined,
                    color: group.exitBlockReason(m) != null
                        ? AppColors.textSecondary
                        : const Color(0xFFD32F2F),
                  ),
                  title: const Text('Remove member'),
                  subtitle: group.exitBlockReason(m) != null
                      ? Text(
                          group.exitBlockReason(m)!,
                          style: const TextStyle(fontSize: 12),
                        )
                      : const Text(
                          'Blocked mid-cycle if they paid in or got payout',
                          style: TextStyle(fontSize: 12),
                        ),
                  onTap: () {
                    final block = group.exitBlockReason(m);
                    Navigator.pop(ctx);
                    if (block != null) {
                      _toast(block, ok: false);
                      return;
                    }
                    final ok = AppState().removeMember(group.id, m.id);
                    _toast(
                      ok
                          ? '${m.name} removed'
                          : (AppState().lastError ?? 'Could not remove'),
                      ok: ok,
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickScheduleStart(SusuGroup group) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    final ok = AppState().rebuildScheduleDates(group.id, picked);
    _toast(ok ? 'Schedule updated' : (AppState().lastError ?? 'Failed'),
        ok: ok);
  }

  void _menuAction(SusuGroup group, String action) async {
    switch (action) {
      case 'edit':
        _editGroup(group);
        break;
      case 'share':
        _shareInvite(group);
        break;
      case 'history':
        _showHistories(group);
        break;
      case 'schedule':
        _pickScheduleStart(group);
        break;
      case 'archive':
        final wasArchived = group.isArchived;
        final ok =
            AppState().archiveGroup(group.id, archived: !wasArchived);
        _toast(
          ok
              ? (wasArchived ? 'Group unarchived' : 'Group archived')
              : (AppState().lastError ?? 'Failed'),
          ok: ok,
        );
        break;
      case 'leave':
        if (!group.canYouLeave) {
          _toast(
            group.exitBlockReason(
                  group.memberList.firstWhere((m) => m.isYou),
                ) ??
                'You cannot leave this group yet.',
            ok: false,
          );
          return;
        }
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave group?'),
            content: Text('Leave “${group.name}”?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Leave')),
            ],
          ),
        );
        if (leave == true) {
          final ok = AppState().leaveGroup(group.id);
          if (ok && mounted) {
            Navigator.of(context).maybePop();
          } else {
            _toast(AppState().lastError ?? 'Could not leave', ok: false);
          }
        }
        break;
      case 'dissolve':
        final dissolve = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Dissolve group?'),
            content: Text(
                'This permanently closes “${group.name}” on this device.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Dissolve',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (dissolve == true) {
          final ok = AppState().dissolveGroup(group.id);
          if (ok && mounted) {
            Navigator.of(context).maybePop();
          } else {
            _toast(AppState().lastError ?? 'Could not dissolve', ok: false);
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        if (state.isLoadingGroups) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.darkGreen),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: const Padding(
              padding: EdgeInsets.all(20),
              child: ShimmerCardPlaceholder(height: 220),
            ),
          );
        }

        final id = _resolvedId;
        final group = id == null ? null : state.groupById(id);
        if (group == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.darkGreen),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: EmptyState(
              icon: Icons.groups_outlined,
              title: 'Group not found',
              message: 'This group may have been removed.',
              actionLabel: 'Back',
              onAction: () => Navigator.of(context).maybePop(),
            ),
          );
        }
        group.ensureCollections();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkGreen),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(group.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
            actions: [
              IconButton(
                onPressed: () => _shareInvite(group),
                icon: const Icon(Icons.ios_share_rounded,
                    color: AppColors.darkGreen),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => _menuAction(group, v),
                itemBuilder: (_) => [
                  if (group.role == 'Admin')
                    const PopupMenuItem(value: 'edit', child: Text('Edit group')),
                  const PopupMenuItem(
                      value: 'history', child: Text('Contribution & payout history')),
                  if (group.role == 'Admin')
                    const PopupMenuItem(
                        value: 'schedule', child: Text('Set schedule start date')),
                  if (group.role == 'Admin')
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(group.isArchived ? 'Unarchive' : 'Archive'),
                    ),
                  PopupMenuItem(
                    value: 'leave',
                    enabled: group.canYouLeave,
                    child: Text(
                      group.canYouLeave
                          ? 'Leave group'
                          : 'Leave group (locked)',
                      style: TextStyle(
                        color: group.canYouLeave
                            ? null
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (group.role == 'Admin')
                    const PopupMenuItem(
                      value: 'dissolve',
                      child: Text('Dissolve group',
                          style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabs,
              labelColor: AppColors.darkGreen,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.vibrantGreen,
              tabs: [
                const Tab(text: 'Overview'),
                Tab(
                  child: Badge(
                    isLabelVisible: group.pendingInvites > 0,
                    label: Text('${group.pendingInvites}'),
                    child: const Text('Members'),
                  ),
                ),
                const Tab(text: 'Schedule'),
                Tab(
                  child: Badge(
                    isLabelVisible: group.unreadChatCount > 0,
                    label: Text('${group.unreadChatCount}'),
                    child: const Text('Chat'),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _overview(group),
              _members(group),
              _schedule(group),
              _chat(group),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!group.canClaimPayout || group.youHavePaidThisRound)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          group.youHavePaidThisRound && !group.canClaimPayout
                              ? group.payoutBlockReason
                              : group.youHavePaidThisRound
                                  ? group.contributeBlockReason
                                  : group.payoutBlockReason.isEmpty
                                      ? 'Ready when you are.'
                                      : group.payoutBlockReason,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: group.youHavePaidThisRound
                                ? null
                                : () => _confirmContribute(group),
                            child: Text(
                              group.youHavePaidThisRound
                                  ? 'Paid this round'
                                  : 'Contribute GHS ${group.contribution.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: group.canClaimPayout
                                ? () => _confirmPayout(group)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.vibrantGreen,
                              disabledBackgroundColor: const Color(0xFFE0E0E0),
                              foregroundColor: AppColors.darkGreenAccent,
                            ),
                            child: Text(
                              group.canClaimPayout
                                  ? 'Claim Payout'
                                  : group.isYourPayoutTurn
                                      ? 'Awaiting funds'
                                      : 'Not your turn',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _overview(SusuGroup group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [AppColors.darkGreen, AppColors.cardGradientEnd],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${group.role} · #${group.yourPosition} in rotation',
                    style: const TextStyle(
                        color: Color(0xFFA3B3A9), fontSize: 12)),
                const SizedBox(height: 8),
                Text('GHS ${group.poolAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 14),
                Text(
                  'Round GHS ${group.collectedThisRound.toStringAsFixed(0)} / ${group.roundTarget.toStringAsFixed(0)} · Next ${group.nextPayout}',
                  style: const TextStyle(color: Color(0xFFA3B3A9), fontSize: 12),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: group.roundProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.vibrantGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                  color: AppColors.notchColor.withValues(alpha: 0.3)),
            ),
            tileColor: Colors.white,
            leading: const Icon(Icons.history_rounded,
                color: AppColors.forestGreen),
            title: const Text('View contribution & payout history',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showHistories(group),
          ),
          const SizedBox(height: 16),
          const Text('Group Rules',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          ...group.rules.map(
            (r) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.notchColor.withValues(alpha: 0.3)),
              ),
              child: Text(r,
                  style: const TextStyle(
                      color: AppColors.darkGreen, height: 1.35)),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _members(SusuGroup group) {
    final q = _memberQuery.toLowerCase();
    final members = group.memberList
        .where((m) =>
            q.isEmpty ||
            m.name.toLowerCase().contains(q) ||
            m.phone.toLowerCase().contains(q))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            onChanged: (v) => setState(() => _memberQuery = v),
            decoration: InputDecoration(
              hintText: 'Search members',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.notchColor.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ),
        Expanded(
          child: members.isEmpty
              ? const EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No members found',
                  message: 'Try another search.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return ListTile(
                      onTap: () => _memberSheet(group, m),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: m.status == 'pending'
                              ? const Color(0xFFFFB74D)
                              : AppColors.notchColor.withValues(alpha: 0.3),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F8EA),
                        child: Text(m.name.isNotEmpty ? m.name[0] : '?'),
                      ),
                      title: Text(m.isYou ? '${m.name} (You)' : m.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen)),
                      subtitle: Text(
                        m.status == 'pending'
                            ? 'Pending'
                            : m.skippedThisCycle
                                ? 'Skipped · #${m.position}'
                                : '${m.hasPaidThisRound ? 'Paid' : 'Unpaid'} · #${m.position}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _schedule(SusuGroup group) {
    if (group.schedule.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'No rotation yet',
        message: 'Set a start date to build the payout calendar.',
        actionLabel: group.role == 'Admin' ? 'Set start date' : null,
        onAction:
            group.role == 'Admin' ? () => _pickScheduleStart(group) : null,
      );
    }

    if (group.role != 'Admin') {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: group.schedule.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _scheduleTile(group.schedule[i], i),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: group.schedule.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        AppState().reorderSchedule(group.id, oldIndex, newIndex);
      },
      itemBuilder: (context, i) {
        final s = group.schedule[i];
        return Container(
          key: ValueKey('sched_${group.id}_$i${s.memberName}'),
          margin: const EdgeInsets.only(bottom: 8),
          child: _scheduleTile(s, i),
        );
      },
    );
  }

  Widget _scheduleTile(RotationSlot s, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: s.isCurrent
            ? AppColors.vibrantGreen.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: s.isCurrent
              ? AppColors.vibrantGreen
              : AppColors.notchColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF4F6F5),
            child: Text('#${index + 1}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.memberName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen)),
                Text(s.payoutDate,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            s.isPaidOut
                ? 'Paid out'
                : s.isCurrent
                    ? 'Current'
                    : 'Upcoming',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: s.isPaidOut
                  ? AppColors.forestGreen
                  : s.isCurrent
                      ? const Color(0xFFE65100)
                      : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chat(SusuGroup group) {
    return Column(
      children: [
        Expanded(
          child: group.messages.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No messages yet',
                  message: 'Say hello and coordinate contributions here.',
                  actionLabel: 'Say hello',
                  onAction: () {
                    AppState().sendGroupMessage(
                        group.id, 'Hello everyone 👋');
                  },
                )
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: group.messages.length,
                  itemBuilder: (_, index) {
                    final msg = group.messages[index];
                    if (msg.isSystem) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Center(
                          child: Text(msg.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ),
                      );
                    }
                    return Align(
                      alignment: msg.isYou
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: msg.isYou
                            ? () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (ctx) => SafeArea(
                                    child: ListTile(
                                      leading: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      title: const Text('Delete message'),
                                      onTap: () {
                                        AppState().deleteGroupMessage(
                                            group.id, msg.id);
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: msg.isYou
                                ? AppColors.vibrantGreen.withValues(alpha: 0.35)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.notchColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg.senderName,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.forestGreen)),
                              const SizedBox(height: 4),
                              Text(msg.text),
                              const SizedBox(height: 4),
                              Text(msg.time,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Message the group…',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.vibrantGreen,
                  child: IconButton(
                    onPressed: () {
                      AppState()
                          .sendGroupMessage(group.id, _chatController.text);
                      _chatController.clear();
                    },
                    icon: const Icon(Icons.send_rounded,
                        color: AppColors.darkGreenAccent, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
