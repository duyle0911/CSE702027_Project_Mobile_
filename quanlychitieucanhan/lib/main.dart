import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// i18n
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'models/expense_model.dart';
import 'models/app_lang.dart'; // 👈 thêm: model đổi ngôn ngữ

import 'screens/home_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/transaction_list_screen.dart';
import 'screens/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 👇 load ngôn ngữ đã lưu
  final appLang = AppLang();
  await appLang.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseModel()),
        ChangeNotifierProvider(create: (_) => appLang),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('username');
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0A84FF);

    return MaterialApp(
      // 🔤 Bật i18n cho toàn app
      locale: context.watch<AppLang>().locale, // 👈 nhận locale đang chọn
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
      // locale: const Locale('vi'), // (tuỳ chọn) ép mặc định

      title: 'Quản Lý Chi Tiêu',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        splashFactory: InkSparkle.splashFactory,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: seed, width: 1.4),
          ),
        ),
        // ✅ cardTheme dùng CardTheme (không phải CardThemeData)
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _checkLogin(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return snap.data! ? const HomePage() : const LoginScreen();
              },
            ),
        '/transactions': (context) => const TransactionListScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _pages = const <Widget>[
    HomeScreen(),
    TransactionScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // shorthand

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _index, children: _pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: t.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: const Icon(Icons.add_circle),
              label: t.navTransactions,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: t.navStats,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: t.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
