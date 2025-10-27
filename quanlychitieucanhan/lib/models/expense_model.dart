// lib/models/expense_model.dart
import 'dart:collection';
import 'package:flutter/foundation.dart';

enum LoaiGiaoDich { thu, chi }

class GiaoDich {
  final String id;
  final LoaiGiaoDich loai;
  final double soTien;
  final String ghiChu;
  final String danhMuc;
  final DateTime thoiGian;

  const GiaoDich({
    required this.id,
    required this.loai,
    required this.soTien,
    required this.ghiChu,
    required this.danhMuc,
    required this.thoiGian,
  });

  GiaoDich copyWith({
    String? id,
    LoaiGiaoDich? loai,
    double? soTien,
    String? ghiChu,
    String? danhMuc,
    DateTime? thoiGian,
  }) {
    return GiaoDich(
      id: id ?? this.id,
      loai: loai ?? this.loai,
      soTien: soTien ?? this.soTien,
      ghiChu: ghiChu ?? this.ghiChu,
      danhMuc: danhMuc ?? this.danhMuc,
      thoiGian: thoiGian ?? this.thoiGian,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'loai': loai.name,
        'soTien': soTien,
        'ghiChu': ghiChu,
        'danhMuc': danhMuc,
        'thoiGian': thoiGian.toIso8601String(),
      };

  factory GiaoDich.fromJson(Map<String, dynamic> json) {
    return GiaoDich(
      id: json['id'] as String,
      loai: (json['loai'] as String) == 'thu'
          ? LoaiGiaoDich.thu
          : LoaiGiaoDich.chi,
      soTien: (json['soTien'] as num).toDouble(),
      ghiChu: json['ghiChu'] as String,
      danhMuc: json['danhMuc'] as String,
      thoiGian: DateTime.parse(json['thoiGian'] as String),
    );
  }

  // Alias thuận tiện cho UI
  String get type => loai == LoaiGiaoDich.thu ? 'income' : 'expense';
  double get amount => soTien;
  String get note => ghiChu;
  String get category => danhMuc;
  DateTime get date => thoiGian;
}

// 👉 typedef để các widget dùng kiểu này
typedef TransactionItem = GiaoDich;

class ExpenseModel extends ChangeNotifier {
  double _tongThu = 0;
  double _tongChi = 0;
  final List<GiaoDich> _dsGiaoDich = [];

  final Set<String> _danhMucThu = {'Lương', 'Thưởng', 'Quà tặng'};
  final Set<String> _danhMucChi = {'Ăn uống', 'Đi lại', 'Mua sắm', 'Hóa đơn'};

  // --- Getters “mới” mà các màn hình đang gọi
  double get income => _tongThu;
  double get expense => _tongChi;
  double get balance => _tongThu - _tongChi;

  UnmodifiableListView<GiaoDich> get giaoDichs =>
      UnmodifiableListView(_dsGiaoDich);

  // Cho code cũ đang dùng
  List<GiaoDich> get transactions => giaoDichs;

  List<String> get incomeCategories => List.unmodifiable(_danhMucThu);
  List<String> get expenseCategories => List.unmodifiable(_danhMucChi);

  // --- Danh mục
  bool addIncomeCategory(String name) {
    final t = name.trim();
    if (t.isEmpty) return false;
    final ok = _danhMucThu.add(t);
    if (ok) notifyListeners();
    return ok;
  }

  bool addExpenseCategory(String name) {
    final t = name.trim();
    if (t.isEmpty) return false;
    final ok = _danhMucChi.add(t);
    if (ok) notifyListeners();
    return ok;
  }

  // --- Giao dịch
  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

  void addIncome(double amount, String note, String category,
      [DateTime? date]) {
    if (amount <= 0) return;
    final gd = GiaoDich(
      id: _genId(),
      loai: LoaiGiaoDich.thu,
      soTien: amount,
      ghiChu: note,
      danhMuc: category,
      thoiGian: date ?? DateTime.now(),
    );
    _dsGiaoDich.add(gd);
    _tongThu += amount;
    notifyListeners();
  }

  void addExpense(double amount, String note, String category,
      [DateTime? date]) {
    if (amount <= 0) return;
    final gd = GiaoDich(
      id: _genId(),
      loai: LoaiGiaoDich.chi,
      soTien: amount,
      ghiChu: note,
      danhMuc: category,
      thoiGian: date ?? DateTime.now(),
    );
    _dsGiaoDich.add(gd);
    _tongChi += amount;
    notifyListeners();
  }

  void addTransaction({
    required String type,
    required double amount,
    required String note,
    required String category,
    DateTime? date,
  }) {
    if (type == 'income') {
      addIncome(amount, note, category, date);
    } else {
      addExpense(amount, note, category, date);
    }
  }

  double totalAmount({required String type, String? category}) {
    final loai = type == 'income' ? LoaiGiaoDich.thu : LoaiGiaoDich.chi;
    return _dsGiaoDich.where((t) {
      final okLoai = t.loai == loai;
      final okCat = category == null || t.danhMuc == category;
      return okLoai && okCat;
    }).fold(0.0, (s, e) => s + e.soTien);
  }

  bool capNhatGiaoDich(String id, GiaoDich moi) {
    final idx = _dsGiaoDich.indexWhere((e) => e.id == id);
    if (idx == -1) return false;

    final cu = _dsGiaoDich[idx];
    if (cu.loai == LoaiGiaoDich.thu) _tongThu -= cu.soTien;
    if (cu.loai == LoaiGiaoDich.chi) _tongChi -= cu.soTien;

    _dsGiaoDich[idx] = moi.copyWith(id: id);

    if (moi.loai == LoaiGiaoDich.thu) _tongThu += moi.soTien;
    if (moi.loai == LoaiGiaoDich.chi) _tongChi += moi.soTien;

    notifyListeners();
    return true;
  }

  bool xoaGiaoDich(String id) {
    final idx = _dsGiaoDich.indexWhere((e) => e.id == id);
    if (idx == -1) return false;
    final g = _dsGiaoDich.removeAt(idx);
    if (g.loai == LoaiGiaoDich.thu) _tongThu -= g.soTien;
    if (g.loai == LoaiGiaoDich.chi) _tongChi -= g.soTien;
    notifyListeners();
    return true;
  }

  void xoaTatCa() {
    _dsGiaoDich.clear();
    _tongThu = 0;
    _tongChi = 0;
    notifyListeners();
  }
}
