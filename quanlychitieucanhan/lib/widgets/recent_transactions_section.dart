import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class RecentTransactionsSection extends StatelessWidget {
  final ExpenseModel expense;
  const RecentTransactionsSection({super.key, required this.expense});

  static final _fmtDate = DateFormat('dd/MM/yyyy');
  static final _fmtMoney = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  String _friendlyDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);

    if (that == today) return 'Hôm nay';
    if (that == today.subtract(const Duration(days: 1))) return 'Hôm qua';
    return _fmtDate.format(d);
  }

  @override
  Widget build(BuildContext context) {
    final recent =
        (expense.transactions.toList()
              ..sort((a, b) => b.date.compareTo(a.date)))
            .take(5)
            .toList();

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.blueGrey.withOpacity(0.6),
                size: 40,
              ),
              const SizedBox(height: 8),
              const Text(
                'Chưa có giao dịch nào',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hãy thêm giao dịch đầu tiên để bắt đầu theo dõi!',
                style: TextStyle(color: Colors.black45),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${recent.length}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/transactions'),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          itemCount: recent.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final t = recent[i];
            final isIncome = t.type == 'income';
            final color = isIncome ? Colors.green : Colors.redAccent;
            final sign = isIncome ? '+' : '-';

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(
                    isIncome ? Icons.south_west : Icons.north_east,
                    color: color,
                  ),
                ),
                title: Text(
                  t.note.isNotEmpty ? t.note : t.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _friendlyDate(t.date),
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  '$sign ${_fmtMoney.format(t.amount)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  final text = '$sign ${_fmtMoney.format(t.amount)}';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Đã sao chép: $text')));
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
