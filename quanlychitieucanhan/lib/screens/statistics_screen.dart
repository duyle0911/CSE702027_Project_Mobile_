import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../widgets/statistics_chart.dart';
import '../widgets/statistics_summary.dart';
import '../widgets/statistics_category_list.dart';
import '../widgets/statistics_search.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _filter = 'all';
  String _searchText = '';
  String _selectedChartType = 'expense';
  DateTimeRange? _customRange;
  final _searchController = TextEditingController();

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
    final theme = Theme.of(context);
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            tooltip: 'Chọn khoảng ngày',
            onPressed: _pickCustomRange,
            icon: const Icon(Icons.date_range),
          ),
          PopupMenuButton<String>(
            tooltip: 'Bộ lọc nhanh',
            onSelected: _selectFilter,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Tất cả')),
              PopupMenuItem(value: 'today', child: Text('Hôm nay')),
              PopupMenuItem(value: 'month', child: Text('Tháng này')),
              PopupMenuItem(value: 'custom', child: Text('Chọn khoảng...')),
            ],
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          StatisticsSearch(
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
                'Khoảng: ${df.format(_customRange!.start)} - ${df.format(_customRange!.end)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'income',
                  icon: Icon(Icons.trending_up),
                  label: Text('Thu'),
                ),
                ButtonSegment(
                  value: 'expense',
                  icon: Icon(Icons.trending_down),
                  label: Text('Chi'),
                ),
              ],
              selected: {_selectedChartType},
              onSelectionChanged: (set) =>
                  setState(() => _selectedChartType = set.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          StatisticsSummary(
            expense: expense,
            selectedChartType: _selectedChartType,
            onSelectType: (type) => setState(() => _selectedChartType = type),
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),

          StatisticsChart(
            expense: expense,
            selectedChartType: _selectedChartType,
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StatisticsCategoryList(
                expense: expense,
                selectedChartType: _selectedChartType,
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
