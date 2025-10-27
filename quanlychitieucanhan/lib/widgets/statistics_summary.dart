import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class StatisticsSummary extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final Function(String) onSelectType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsSummary({
    super.key,
    required this.expense,
    required this.selectedChartType,
    required this.onSelectType,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  String _periodLabel() {
    final fmt = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();
    return switch (filter) {
      'today' => 'Hôm nay • ${fmt.format(now)}',
      'month' => 'Tháng này • ${DateFormat('MM/yyyy').format(now)}',
      'custom' when customRange != null =>
        'Khoảng: ${fmt.format(customRange!.start)} - ${fmt.format(customRange!.end)}',
      _ => 'Toàn thời gian',
    };
  }

  @override
  Widget build(BuildContext context) {
    final fmtMoney = NumberFormat.currency(
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
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }
    final net = totalIncome - totalExpense;
    final sum = (totalIncome + totalExpense);
    final pIncome = sum == 0 ? 0.0 : totalIncome / sum;
    final pExpense = sum == 0 ? 0.0 : totalExpense / sum;

    final isIncomeSelected = selectedChartType == 'income';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, size: 18, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Tóm tắt thống kê',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _periodLabel(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      'Thu: ${fmtMoney.format(totalIncome)}'
                      '  (${(pIncome * 100).toStringAsFixed(0)}%)',
                    ),
                    selected: isIncomeSelected,
                    onSelected: (_) => onSelectType('income'),
                    avatar: const Icon(
                      Icons.trending_up,
                      size: 18,
                      color: Colors.green,
                    ),
                    selectedColor: Colors.green.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: isIncomeSelected
                          ? Colors.green.shade700
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(
                      'Chi: ${fmtMoney.format(totalExpense)}'
                      '  (${(pExpense * 100).toStringAsFixed(0)}%)',
                    ),
                    selected: !isIncomeSelected,
                    onSelected: (_) => onSelectType('expense'),
                    avatar: const Icon(
                      Icons.trending_down,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    selectedColor: Colors.redAccent.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: !isIncomeSelected
                          ? Colors.redAccent.shade200
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pIncome.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.redAccent.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Thu nhiều hơn  ⟶',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    '⟵  Chi nhiều hơn',
                    style: TextStyle(color: Colors.redAccent),
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
                      fmtMoney.format(net),
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
}
