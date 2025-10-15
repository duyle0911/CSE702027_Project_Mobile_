import 'package:flutter/material.dart';
import '../models/mo_hinh_chi_tieu.dart';

class ManHinhDanhSachGiaoDich extends StatelessWidget {
  final List<GiaoDich> danhSach;

  const ManHinhDanhSachGiaoDich({super.key, required this.danhSach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách giao dịch")),
      body: ListView.builder(
        itemCount: danhSach.length,
        itemBuilder: (context, index) {
          final gd = danhSach[index];
          return ListTile(
            title: Text("${gd.danhMuc} (${gd.loai})"),
            subtitle: Text(gd.ghiChu),
            trailing: Text("${gd.soTien.toStringAsFixed(0)} ₫"),
          );
        },
      ),
    );
  }
}
