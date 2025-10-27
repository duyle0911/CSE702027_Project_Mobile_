// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navTransactions => 'Giao dịch';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navProfile => 'Cá nhân';

  @override
  String get appTitle => 'Tổng quan chi tiêu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get confirmLogoutTitle => 'Đăng xuất';

  @override
  String get confirmLogoutMsg => 'Bạn có chắc muốn đăng xuất khỏi ứng dụng?';

  @override
  String get balance => 'Số dư hiện tại';

  @override
  String get income => 'Thu';

  @override
  String get expense => 'Chi';

  @override
  String get addIncome => 'Thêm khoản thu';

  @override
  String get addExpense => 'Thêm khoản chi';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get all => 'Tất cả';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageVi => 'Tiếng Việt';

  @override
  String get languageEn => 'Tiếng Anh';

  @override
  String get aboutTeam => 'Thông tin nhóm';

  @override
  String get aboutContent =>
      'Ứng dụng thuộc bài tập lớn môn Lập trình cho thiết bị di động.';

  @override
  String get settings => 'Cài đặt';
}
