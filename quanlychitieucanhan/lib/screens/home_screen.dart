import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/recent_transactions_section.dart';

import 'transaction/add_income_screen.dart';
import 'transaction/add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goAddIncome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
    );
  }

  void _goAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  void _goAllTransactions(BuildContext context) {
    Navigator.pushNamed(context, '/transactions');
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.select<ExpenseModel, double>((m) => m.balance);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan chi tiêu'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/img/banner_wallet.jpg',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          BalanceCard(balance: balance),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _goAddIncome(context),
                    icon: const Icon(Icons.south_west),
                    label: const Text('Thêm THU'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _goAddExpense(context),
                    icon: const Icon(Icons.north_east),
                    label: const Text('Thêm CHI'),
                    style: FilledButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Consumer<ExpenseModel>(
              builder: (_, m, __) => SummaryCard(expense: m),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Giao dịch gần đây',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _goAllTransactions(context),
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Consumer<ExpenseModel>(
              builder: (_, m, __) => RecentTransactionsSection(expense: m),
            ),
          ),
        ],
      ),
    );
  }
}
