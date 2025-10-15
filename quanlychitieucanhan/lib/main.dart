import 'package:flutter/material.dart';
import 'screens/man_hinh_trang_chu.dart';

void main() {
  runApp(const QuanLyChiTieuApp());
}

class QuanLyChiTieuApp extends StatelessWidget {
  const QuanLyChiTieuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý chi tiêu cá nhân',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: const ManHinhTrangChu(),
    );
  }
}
