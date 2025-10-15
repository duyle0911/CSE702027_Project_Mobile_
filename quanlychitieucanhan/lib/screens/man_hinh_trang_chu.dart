import 'package:flutter/material.dart';
import 'man_hinh_them_giao_dich.dart';

class ManHinhTrangChu extends StatelessWidget {
  const ManHinhTrangChu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💰 Quản lý chi tiêu cá nhân"),
        centerTitle: true,
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
                final gd = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManHinhThemGiaoDich(),
                  ),
                );

                if (gd != null) {
                  print('Giao dịch mới: ${gd.danhMuc} - ${gd.soTien}');
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Thêm giao dịch mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
