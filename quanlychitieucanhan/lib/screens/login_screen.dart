import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _prefillUsername();
  }

  Future<void> _prefillUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString('last_username');
    if (last != null && mounted) {
      _username.text = last;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _username.text.trim();
    final password = _password.text.trim();

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    final savedPassword = prefs.getString('user_$username');
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (savedPassword == null || savedPassword != password) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sai tên đăng nhập hoặc mật khẩu')),
      );
      return;
    }

    await prefs.setString('username', username);
    if (_rememberMe) {
      await prefs.setString('last_username', username);
    } else {
      await prefs.remove('last_username');
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _goRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tính năng đặt lại mật khẩu (demo) – hãy liên hệ hỗ trợ.',
        ),
      ),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Image.asset(
                        'assets/img/logo.png',
                        height: 72,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.account_circle,
                          size: 72,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Text(
                      'Đăng nhập',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
                            autofillHints: const [AutofillHints.username],
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
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập tên người dùng'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip: _obscure
                                    ? 'Hiện mật khẩu'
                                    : 'Ẩn mật khẩu',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Vui lòng nhập mật khẩu'
                                : null,
                            onFieldSubmitted: (_) =>
                                _isLoading ? null : _login(),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? true),
                              ),
                              const Text('Ghi nhớ'),
                              const Spacer(),
                              TextButton(
                                onPressed: _forgotPassword,
                                child: const Text('Quên mật khẩu?'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
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
                                      'Đăng nhập',
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
                              const Text('Chưa có tài khoản?'),
                              TextButton(
                                onPressed: _goRegister,
                                child: const Text('Đăng ký ngay'),
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
