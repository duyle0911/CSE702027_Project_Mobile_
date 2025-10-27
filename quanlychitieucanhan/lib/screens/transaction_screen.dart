import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import 'transaction_entry_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _section = 'income';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _addCategory(ExpenseModel model, bool isIncome) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Thêm danh mục ${isIncome ? 'thu nhập' : 'chi tiêu'}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tên danh mục',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final list = isIncome
                  ? model.incomeCategories
                  : model.expenseCategories;
              if (list
                  .map((e) => e.toLowerCase())
                  .contains(name.toLowerCase())) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Danh mục "$name" đã tồn tại')),
                );
                return;
              }

              if (isIncome) {
                model.addIncomeCategory(name);
              } else {
                model.addExpenseCategory(name);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã thêm danh mục: $name')),
              );
              setState(() {});
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpenseModel>();
    final isIncome = _section == 'income';
    final Color accent = isIncome ? Colors.green : Colors.redAccent;
    final IconData arrowIcon = isIncome ? Icons.south_west : Icons.north_east;

    final allCategories = isIncome
        ? model.incomeCategories
        : model.expenseCategories;
    final q = _search.text.trim().toLowerCase();
    final categories = allCategories
        .where((c) => c.toLowerCase().contains(q))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        icon: const Icon(Icons.add),
        label: const Text('Thêm danh mục'),
        onPressed: () => _addCategory(model, isIncome),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'income',
                icon: Icon(Icons.trending_up),
                label: Text('Thu nhập'),
              ),
              ButtonSegment(
                value: 'expense',
                icon: Icon(Icons.trending_down),
                label: Text('Chi tiêu'),
              ),
            ],
            selected: {_section},
            onSelectionChanged: (v) => setState(() {
              _section = v.first;
              _search.clear();
            }),
            showSelectedIcon: false,
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Tìm danh mục…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: q.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 12),

          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Không có danh mục phù hợp',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];

                final total = model.totalAmount(
                  type: isIncome ? 'income' : 'expense',
                  category: cat,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1.5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accent.withOpacity(0.12),
                      child: Icon(arrowIcon, color: accent),
                    ),
                    title: Text(
                      cat,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: total > 0
                        ? Text(
                            '${isIncome ? 'Đã thu' : 'Đã chi'}: ${total.toStringAsFixed(0)} đ',
                            style: const TextStyle(color: Colors.grey),
                          )
                        : const Text(
                            'Chưa có giao dịch',
                            style: TextStyle(color: Colors.grey),
                          ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionEntryScreen(
                            type: _section,
                            category: cat,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
