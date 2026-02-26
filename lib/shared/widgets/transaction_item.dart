import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final bool isIncome;
  final String? emoji;
  final IconData? icon;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.emoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? Colors.green : Colors.red;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: emoji != null
                  ? Text(emoji!, style: const TextStyle(fontSize: 24))
                  : Icon(icon, color: color, size: 24),
            ),

            const SizedBox(width: 12),

            // TITLE + DATE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // AMOUNT
            Text(
              "${isIncome ? "+" : "-"}${amount.toStringAsFixed(2)} F",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
