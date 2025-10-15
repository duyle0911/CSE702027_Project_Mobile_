class GiaoDich {
  final String loai; // 'thu' hoặc 'chi'
  final String danhMuc;
  final double soTien;
  final String ghiChu;
  final DateTime ngay;

  GiaoDich({
    required this.loai,
    required this.danhMuc,
    required this.soTien,
    required this.ghiChu,
    required this.ngay,
  });
}
