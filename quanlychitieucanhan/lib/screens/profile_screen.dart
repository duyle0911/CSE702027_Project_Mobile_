import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense_model.dart';
import '../models/app_lang.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.confirmLogoutTitle),
        content: Text(t.confirmLogoutMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.logout),
          ),
        ],
      ),
    );
    if (ok == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final m = context.watch<ExpenseModel>();

    final locale = Localizations.localeOf(context).toString();
    final currency = NumberFormat.currency(
      locale: locale,
      symbol: locale.startsWith('vi') ? '₫' : 'VND',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navProfile),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, size: 44, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snap) {
                        final username = snap.hasData
                            ? (snap.data!.getString('username') ??
                                (locale.startsWith('vi')
                                    ? 'Người dùng'
                                    : 'User'))
                            : (locale.startsWith('vi') ? 'Người dùng' : 'User');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              locale.startsWith('vi')
                                  ? 'Quản lý chi tiêu cá nhân'
                                  : 'Personal expense manager',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: t.income,
                  value: currency.format(m.income),
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: t.expense,
                  value: currency.format(m.expense),
                  icon: Icons.trending_down,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BalanceTile(
            balance: currency.format(m.balance),
            subtitle: "${t.income} - ${t.expense}",
            title: t.balance,
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: Text(locale.startsWith('vi')
                      ? 'Đổi mật khẩu'
                      : 'Change password'),
                  subtitle: Text(locale.startsWith('vi')
                      ? 'Thiết lập/đổi mật khẩu đăng nhập'
                      : 'Set/change the login password'),
                  onTap: () => Navigator.pushNamed(context, '/change-password'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(t.language),
                  trailing: DropdownButton<String>(
                    value:
                        (context.watch<AppLang>().locale ?? const Locale('vi'))
                            .languageCode,
                    items: [
                      DropdownMenuItem(value: 'vi', child: Text(t.languageVi)),
                      DropdownMenuItem(value: 'en', child: Text(t.languageEn)),
                    ],
                    onChanged: (code) {
                      if (code != null) {
                        context.read<AppLang>().setLocale(code);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(t.settings),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        locale.startsWith('vi')
                            ? 'Chức năng demo: chưa triển khai'
                            : 'Demo feature: not implemented yet',
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    t.logout,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String balance;
  final String title;
  final String subtitle;
  const _BalanceTile({
    required this.balance,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
          child: Icon(Icons.account_balance_wallet,
              color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          balance,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
