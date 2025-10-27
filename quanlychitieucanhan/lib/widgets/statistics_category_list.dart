import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class StatisticsCategoryList extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsCategoryList({
    super.key,
    required this.expense,
    required this.selectedChartType,
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
      bool matchFilter = switch (filter) {
        'all' => true,
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

    final Map<String, double> byCategory = {};
    final Map<String, int> countByCategory = {};
    double total = 0;

    for (final t in filtered) {
      final matchType =
          (selectedChartType == 'income' && t.type == 'income') ||
          (selectedChartType == 'expense' && t.type == 'expense');
      if (!matchType) continue;

      total += t.amount;
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      countByCategory[t.category] = (countByCategory[t.category] ?? 0) + 1;
    }

    final items = byCategory.entries.map((e) {
      final amount = e.value;
      final pct = total == 0 ? 0.0 : amount / total;
      final cnt = countByCategory[e.key] ?? 0;
      return _CategoryRow(
        name: e.key,
        amount: amount,
        percent: pct,
        count: cnt,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            selectedChartType == 'income'
                ? 'Không có dữ liệu thu nhập theo bộ lọc hiện tại'
                : 'Không có dữ liệu chi tiêu theo bộ lọc hiện tại',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final it = items[i];
        final color = selectedChartType == 'income'
            ? Colors.green
            : Colors.redAccent;
        final bg = color.withOpacity(0.12);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: bg,
                  child: Icon(
                    selectedChartType == 'income'
                        ? Icons.south_west
                        : Icons.north_east,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              it.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fmt.format(it.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: it.percent.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: bg,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 56,
                            child: Text(
                              '${(it.percent * 100).toStringAsFixed(1)}%',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Giao dịch: ${it.count}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryRow {
  final String name;
  final double amount;
  final double percent;
  final int count;

  _CategoryRow({
    required this.name,
    required this.amount,
    required this.percent,
    required this.count,
  });
}
