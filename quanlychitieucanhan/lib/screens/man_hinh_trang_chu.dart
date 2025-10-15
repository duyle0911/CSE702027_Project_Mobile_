import 'package:flutter/material.dart';

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
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Chuyển sang màn hình thêm giao dịch
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
