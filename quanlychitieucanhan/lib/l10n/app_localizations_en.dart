// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navStats => 'Statistics';

  @override
  String get navProfile => 'Profile';

  @override
  String get appTitle => 'Expense Overview';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogoutTitle => 'Logout';

  @override
  String get confirmLogoutMsg => 'Are you sure you want to log out?';

  @override
  String get balance => 'Current balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get seeAll => 'See all';

  @override
  String get all => 'All';

  @override
  String get language => 'Language';

  @override
  String get languageVi => 'Vietnamese';

  @override
  String get languageEn => 'English';

  @override
  String get aboutTeam => 'About the Team';

  @override
  String get aboutContent =>
      'This app is a coursework project for Mobile Programming.';

  @override
  String get settings => 'Settings';
}
