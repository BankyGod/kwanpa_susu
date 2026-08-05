import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_loader.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  void _showAddMoMo(BuildContext context) {
    final phoneController = TextEditingController();
    String network = 'MTN Mobile Money';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
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
                    'Add Mobile Money',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: network,
                    decoration: InputDecoration(
                      labelText: 'Network',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'MTN Mobile Money',
                          child: Text('MTN Mobile Money')),
                      DropdownMenuItem(
                          value: 'Telecel Cash', child: Text('Telecel Cash')),
                      DropdownMenuItem(
                          value: 'AT Money', child: Text('AT Money')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModal(() => network = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: '024 123 4567',
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
                        final phone = phoneController.text.trim();
                        if (phone.length < 9) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Enter a valid phone number')),
                          );
                          return;
                        }
                        final masked = phone.length >= 7
                            ? '${phone.substring(0, 3)} *** ${phone.substring(phone.length - 4)}'
                            : phone;
                        final accent = network.contains('MTN')
                            ? const Color(0xFFFFCC00)
                            : network.contains('Telecel')
                                ? const Color(0xFFE50012)
                                : const Color(0xFF0066CC);
                        AppState().addPaymentMethod(
                          name: network,
                          maskedNumber: masked,
                          type: 'momo',
                          accent: accent,
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save Method',
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final methods = state.paymentMethods;
        final momo = methods.where((m) => m.type == 'momo').toList();
        final banks = methods.where((m) => m.type == 'bank').toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.darkGreen),
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
          body: state.isLoadingPayments
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    ShimmerCardPlaceholder(height: 80),
                    SizedBox(height: 12),
                    ShimmerCardPlaceholder(height: 80),
                  ],
                )
              : methods.isEmpty
                  ? EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No payment methods',
                      message:
                          'Add MTN MoMo, Telecel Cash, or a bank card to deposit and withdraw.',
                      actionLabel: 'Add MoMo',
                      onAction: () => _showAddMoMo(context),
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mobile Money',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showAddMoMo(context),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        ...momo.map((m) => _methodTile(context, m)),
                        const SizedBox(height: 16),
                        const Text(
                          'Cards & Bank',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (banks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No bank cards linked yet.',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                          )
                        else
                          ...banks.map((m) => _methodTile(context, m)),
                      ],
                    ),
        );
      },
    );
  }

  Widget _methodTile(BuildContext context, PaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method.isPrimary
              ? AppColors.vibrantGreen
              : AppColors.notchColor.withValues(alpha: 0.3),
          width: method.isPrimary ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: method.accent.withValues(alpha: 0.2),
          child: Icon(
            method.type == 'momo'
                ? Icons.smartphone_rounded
                : Icons.credit_card_rounded,
            color: AppColors.darkGreen,
          ),
        ),
        title: Text(
          method.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
        subtitle: Text(method.maskedNumber),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'primary') {
              AppState().setPrimaryPaymentMethod(method.id);
            } else if (value == 'remove') {
              AppState().removePaymentMethod(method.id);
            }
          },
          itemBuilder: (_) => [
            if (!method.isPrimary)
              const PopupMenuItem(
                  value: 'primary', child: Text('Set as primary')),
            const PopupMenuItem(
              value: 'remove',
              child: Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
