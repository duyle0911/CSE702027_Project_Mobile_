import 'package:flutter/material.dart';
import '../models/mo_hinh_chi_tieu.dart';
import 'man_hinh_them_giao_dich.dart';
import 'man_hinh_danh_sach_giao_dich.dart';

class ManHinhTrangChu extends StatefulWidget {
  const ManHinhTrangChu({super.key});

  @override
  State<ManHinhTrangChu> createState() => _ManHinhTrangChuState();
}

class _ManHinhTrangChuState extends State<ManHinhTrangChu> {
  final List<GiaoDich> _danhSachGiaoDich = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💰 Quản lý chi tiêu cá nhân"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManHinhDanhSachGiaoDich(danhSach: _danhSachGiaoDich),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Chào mừng bạn đến với ứng dụng quản lý chi tiêu!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final gd = await Navigator.push<GiaoDich>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManHinhThemGiaoDich(),
                  ),
                );

                if (gd != null) {
                  setState(() {
                    _danhSachGiaoDich.add(gd);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Đã thêm: ${gd.danhMuc} (${gd.soTien.toStringAsFixed(0)} ₫)",
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Thêm giao dịch mới"),
            ),
          ],
        ),
      ),
    );
  }
}
