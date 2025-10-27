import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();
  bool _loading = false;
  bool _obOld = true, _ob1 = true, _ob2 = true;

  @override
  void dispose() {
    _old.dispose();
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null || username.isEmpty) {
      setState(() => _loading = false);
      _snack('Chưa đăng nhập', err: true);
      return;
    }

    final key = 'user_$username';
    final saved = prefs.getString(key) ?? '';

    final old = _old.text;
    final n1 = _new1.text;
    final n2 = _new2.text;

    String? err;
    if (saved.isNotEmpty && old != saved) {
      err = 'Mật khẩu cũ không đúng';
    } else if (n1.isEmpty || n2.isEmpty) {
      err = 'Vui lòng nhập mật khẩu mới';
    } else if (n1.length < 4) {
      err = 'Mật khẩu mới tối thiểu 4 ký tự (demo)';
    } else if (n1 != n2) {
      err = 'Nhập lại mật khẩu mới chưa khớp';
    }

    if (err != null) {
      setState(() => _loading = false);
      _snack(err, err: true);
      return;
    }

    await prefs.setString(key, n1);
    setState(() => _loading = false);
    _snack('Đổi mật khẩu thành công');
    if (mounted) Navigator.pop(context);
  }

  void _snack(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: err ? Colors.redAccent : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PwdField(
            controller: _old,
            label: 'Mật khẩu cũ',
            hint: 'Bỏ trống nếu chưa từng đặt',
            obscure: _obOld,
            onToggle: () => setState(() => _obOld = !_obOld),
          ),
          const SizedBox(height: 12),
          _PwdField(
            controller: _new1,
            label: 'Mật khẩu mới',
            obscure: _ob1,
            onToggle: () => setState(() => _ob1 = !_ob1),
          ),
          const SizedBox(height: 12),
          _PwdField(
            controller: _new2,
            label: 'Nhập lại mật khẩu mới',
            obscure: _ob2,
            onToggle: () => setState(() => _ob2 = !_ob2),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _loading ? null : _change,
              icon: const Icon(Icons.lock_reset),
              label: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Đổi mật khẩu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PwdField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final VoidCallback onToggle;

  const _PwdField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}
