import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateUsername(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Vui lòng nhập tên người dùng';
    if (s.length < 3) return 'Tên người dùng tối thiểu 3 ký tự';
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(s)) {
      return 'Chỉ dùng chữ, số, ., _, -';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (s.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';

    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$').hasMatch(s)) {
      return 'Nên có cả chữ và số (>=6 ký tự)';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (v != _password.text) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final username = _username.text.trim();
    final password = _password.text;

    if (prefs.containsKey('user_$username')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tên người dùng đã tồn tại')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    await prefs.setString('user_$username', password);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký thành công! Hãy đăng nhập.')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add, size: 72, color: Colors.green),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng ký tài khoản',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _username,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newUsername],
                            decoration: InputDecoration(
                              labelText: 'Tên người dùng',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                            validator: _validateUsername,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _password,
                            obscureText: _obscure1,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure1 = !_obscure1),
                                icon: Icon(
                                  _obscure1
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip: _obscure1
                                    ? 'Hiện mật khẩu'
                                    : 'Ẩn mật khẩu',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _confirm,
                            obscureText: _obscure2,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Xác nhận mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure2 = !_obscure2),
                                icon: Icon(
                                  _obscure2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip: _obscure2
                                    ? 'Hiện mật khẩu'
                                    : 'Ẩn mật khẩu',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: _validateConfirm,
                            onFieldSubmitted: (_) =>
                                _isLoading ? null : _register(),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Đăng ký',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản?'),
                              TextButton(
                                onPressed: _isLoading ? null : _goLogin,
                                child: const Text('Đăng nhập'),
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
          ),
        ),
      ),
    );
  }
}
