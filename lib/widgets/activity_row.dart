import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class ActivityRow extends StatelessWidget {
  final TransactionItem item;
  final bool showDivider;

  const ActivityRow({
    super.key,
    required this.item,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = item.isDeposit;
    final iconBg = isCredit
        ? const Color(0xFFE8F8EA)
        : const Color(0xFFFFEBEE);
    final iconColor = isCredit ? AppColors.forestGreen : const Color(0xFFD32F2F);
    final amountPrefix = isCredit ? '+' : '-';

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category != null && item.category!.isNotEmpty
                        ? '${item.date} · ${item.category}'
                        : item.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix GHS ${item.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCredit ? AppColors.forestGreen : AppColors.darkGreen,
              ),
            ),
          ],
        ),
        if (showDivider)
          const Divider(height: 20, thickness: 1, color: Color(0xFFF5F5F5)),
      ],
    );
  }
}
