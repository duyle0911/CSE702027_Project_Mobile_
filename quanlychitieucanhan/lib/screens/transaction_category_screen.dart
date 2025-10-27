import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import 'transaction_entry_screen.dart';

class TransactionCategoryScreen extends StatefulWidget {
  final String type; // 'income' | 'expense'
  const TransactionCategoryScreen({super.key, required this.type});

  @override
  State<TransactionCategoryScreen> createState() =>
      _TransactionCategoryScreenState();
}

class _TransactionCategoryScreenState extends State<TransactionCategoryScreen> {
  final _search = TextEditingController();

  bool get _isIncome => widget.type == 'income';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _addCategory(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm danh mục'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tên danh mục...',
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
              final text = controller.text.trim();
              if (text.isEmpty) return;

              final model = context.read<ExpenseModel>();
              final current =
                  _isIncome ? model.incomeCategories : model.expenseCategories;

              final exists = current
                  .map((e) => e.toLowerCase())
                  .contains(text.toLowerCase());

              Navigator.pop(context);

              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Danh mục đã tồn tại: $text')),
                );
                return;
              }

              // Gọi hàm thêm (không cần giá trị trả về)
              if (_isIncome) {
                model.addIncomeCategory(text);
              } else {
                model.addExpenseCategory(text);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã thêm: $text')),
              );
              setState(() {});
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _renameCategory(BuildContext context, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi tên danh mục'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tên mới...',
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
              final newName = controller.text.trim();
              if (newName.isEmpty ||
                  newName.toLowerCase() == oldName.toLowerCase()) {
                Navigator.pop(context);
                return;
              }

              final model = context.read<ExpenseModel>();
              final current =
                  _isIncome ? model.incomeCategories : model.expenseCategories;

              final exists = current
                  .map((e) => e.toLowerCase())
                  .contains(newName.toLowerCase());

              Navigator.pop(context);

              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Danh mục đã tồn tại: $newName')),
                );
                return;
              }

              // Demo: thêm tên mới (chưa xoá tên cũ để tránh mất dữ liệu lịch sử)
              if (_isIncome) {
                model.addIncomeCategory(newName);
              } else {
                model.addExpenseCategory(newName);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã thêm danh mục mới: $newName')),
              );
              setState(() {});
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(BuildContext context, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá danh mục'),
        content: Text('Bạn có chắc muốn xoá danh mục "$name"? (Demo xoá UI)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo: Chưa xoá khỏi model để bảo toàn dữ liệu.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpenseModel>();
    final all = _isIncome ? model.incomeCategories : model.expenseCategories;
    final query = _search.text.trim().toLowerCase();
    final filtered = all.where((c) => c.toLowerCase().contains(query)).toList();

    final color = _isIncome ? Colors.green : Colors.redAccent;
    final icon = _isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isIncome ? 'Danh mục Thu nhập' : 'Danh mục Chi tiêu'),
        backgroundColor: color,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context),
        backgroundColor: color,
        icon: const Icon(Icons.add),
        label: const Text('Thêm danh mục'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Tìm danh mục...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
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
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không có danh mục phù hợp'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final name = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1.5,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.12),
                            child: Icon(icon, color: color),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'rename') _renameCategory(context, name);
                              if (v == 'delete') _deleteCategory(context, name);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Đổi tên (demo)'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Xoá (demo)'),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionEntryScreen(
                                  type: widget.type,
                                  category: name,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
