import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class TransactionSummary extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const TransactionSummary({
    super.key,
    required this.expense,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final now = DateTime.now();

    final filtered = expense.transactions.where((t) {
      final matchFilter = switch (filter) {
        'today' =>
          t.date.day == now.day &&
              t.date.month == now.month &&
              t.date.year == now.year,
        'month' => t.date.month == now.month && t.date.year == now.year,
        'custom' when customRange != null =>
          t.date.isAfter(
                customRange!.start.subtract(const Duration(days: 1)),
              ) &&
              t.date.isBefore(customRange!.end.add(const Duration(days: 1))),
        _ => true,
      };

      final q = searchText.toLowerCase();
      final matchSearch =
          t.note.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);

      return matchFilter && matchSearch;
    }).toList();

    double totalIncome = 0, totalExpense = 0;
    for (final t in filtered) {
      if (t.type == 'income')
        totalIncome += t.amount;
      else
        totalExpense += t.amount;
    }
    final net = totalIncome - totalExpense;
    final sum = (totalIncome + totalExpense);
    final pIncome = sum == 0 ? 0.0 : totalIncome / sum;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: const [
                  Icon(Icons.summarize, color: Colors.teal, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tổng kết',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statTile(
                    label: 'Tổng thu',
                    value: fmt.format(totalIncome),
                    color: Colors.green,
                    icon: Icons.trending_up,
                  ),
                  _statTile(
                    label: 'Tổng chi',
                    value: fmt.format(totalExpense),
                    color: Colors.redAccent,
                    icon: Icons.trending_down,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pIncome.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.redAccent.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thu ${(pIncome * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text(
                    'Chi ${((1 - pIncome) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: (net >= 0 ? Colors.green : Colors.redAccent)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      net >= 0
                          ? Icons.account_balance_wallet
                          : Icons.warning_amber_rounded,
                      color: net >= 0 ? Colors.green : Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Số dư ròng: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      fmt.format(net),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: net >= 0 ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _statTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
