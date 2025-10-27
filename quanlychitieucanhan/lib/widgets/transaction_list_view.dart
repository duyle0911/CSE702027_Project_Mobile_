import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';

class TransactionListView extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const TransactionListView({
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
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 56, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Không có giao dịch nào trong thời gian này',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    String keyOf(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final Map<String, List<TransactionItem>> byDay = {};
    for (final t in filtered) {
      (byDay[keyOf(t.date)] ??= []).add(t);
    }

    final dayKeys = byDay.keys.toList()
      ..sort((a, b) {
        final da = DateTime.parse(a);
        final db = DateTime.parse(b);
        return db.compareTo(da);
      });

    String prettyDay(DateTime d) {
      final isToday =
          d.year == now.year && d.month == now.month && d.day == now.day;
      final yesterday = now.subtract(const Duration(days: 1));
      final isYesterday =
          d.year == yesterday.year &&
          d.month == yesterday.month &&
          d.day == yesterday.day;
      if (isToday) return 'Hôm nay';
      if (isYesterday) return 'Hôm qua';
      return DateFormat('dd/MM/yyyy').format(d);
    }

    Widget dayHeader(String k, List<TransactionItem> list) {
      double inc = 0, exp = 0;
      for (final t in list) {
        if (t.type == 'income')
          inc += t.amount;
        else
          exp += t.amount;
      }
      final date = DateTime.parse(k);
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
        child: Row(
          children: [
            Text(
              prettyDay(date),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            _miniPill('+ ${fmt.format(inc)}', Colors.green),
            const SizedBox(width: 8),
            _miniPill('- ${fmt.format(exp)}', Colors.redAccent),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: dayKeys.length,
      itemBuilder: (context, i) {
        final k = dayKeys[i];
        final list = byDay[k]!..sort((a, b) => b.date.compareTo(a.date));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dayHeader(k, list),
            ...list.map((t) => _TransactionTile(item: t, fmt: fmt)).toList(),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  Widget _miniPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final NumberFormat fmt;

  const _TransactionTile({required this.item, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == 'income';
    final icon = isIncome ? Icons.south_west : Icons.north_east;
    final color = isIncome ? Colors.green : Colors.redAccent;
    final time = DateFormat('HH:mm').format(item.date);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
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
                            item.note.isNotEmpty
                                ? item.note
                                : '(Không có ghi chú)',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (isIncome ? '+ ' : '- ') + fmt.format(item.amount),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.category,
                                size: 14,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.category,
                                style: const TextStyle(color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
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
