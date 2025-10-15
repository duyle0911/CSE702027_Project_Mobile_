import 'package:flutter/material.dart';
import '../models/mo_hinh_chi_tieu.dart';

class ManHinhThongKe extends StatelessWidget {
  final List<GiaoDich> danhSach;

  const ManHinhThongKe({super.key, required this.danhSach});

  @override
  Widget build(BuildContext context) {
    double tongThu = danhSach
        .where((gd) => gd.loai == 'thu')
        .fold(0, (sum, gd) => sum + gd.soTien);
    double tongChi = danhSach
        .where((gd) => gd.loai == 'chi')
        .fold(0, (sum, gd) => sum + gd.soTien);
    double soDu = tongThu - tongChi;

    return Scaffold(
      appBar: AppBar(title: const Text("Thống kê chi tiêu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text("Tổng thu"),
                trailing: Text("${tongThu.toStringAsFixed(0)} ₫"),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text("Tổng chi"),
                trailing: Text("${tongChi.toStringAsFixed(0)} ₫"),
              ),
            ),
            Card(
              color: Colors.teal[50],
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.teal,
                ),
                title: const Text("Số dư hiện tại"),
                trailing: Text("${soDu.toStringAsFixed(0)} ₫"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
