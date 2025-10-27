import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../widgets/transaction_search.dart';
import '../widgets/transaction_summary.dart';
import '../widgets/transaction_list_view.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _filter = 'all';
  String _searchText = '';
  final _searchController = TextEditingController();
  DateTimeRange? _customRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _filter = 'custom';
      });
    }
  }

  void _selectFilter(String value) {
    setState(() {
      _filter = value;
      if (value != 'custom') _customRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giao dịch'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            tooltip: 'Chọn khoảng ngày',
            onPressed: _pickCustomRange,
            icon: const Icon(Icons.date_range),
          ),
          PopupMenuButton<String>(
            tooltip: 'Bộ lọc nhanh',
            onSelected: _selectFilter,
            icon: const Icon(Icons.filter_alt),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Tất cả')),
              PopupMenuItem(value: 'today', child: Text('Hôm nay')),
              PopupMenuItem(value: 'month', child: Text('Tháng này')),
              PopupMenuItem(value: 'custom', child: Text('Chọn khoảng...')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TransactionSearch(
            controller: _searchController,
            searchText: _searchText,
            onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
            onClear: () => setState(() => _searchText = ''),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _filter == 'all',
                  onSelected: (_) => _selectFilter('all'),
                ),
                ChoiceChip(
                  label: const Text('Hôm nay'),
                  selected: _filter == 'today',
                  onSelected: (_) => _selectFilter('today'),
                ),
                ChoiceChip(
                  label: const Text('Tháng này'),
                  selected: _filter == 'month',
                  onSelected: (_) => _selectFilter('month'),
                ),
                ChoiceChip(
                  label: const Text('Chọn khoảng…'),
                  selected: _filter == 'custom',
                  onSelected: (_) => _pickCustomRange(),
                ),
              ],
            ),
          ),

          if (_filter == 'custom' && _customRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Khoảng: '
                '${_customRange!.start.day}/${_customRange!.start.month}/${_customRange!.start.year}  -  '
                '${_customRange!.end.day}/${_customRange!.end.month}/${_customRange!.end.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

          TransactionSummary(
            expense: expense,
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TransactionListView(
                expense: expense,
                filter: _filter,
                customRange: _customRange,
                searchText: _searchText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
