import 'package:flutter/material.dart';
import '../models/mo_hinh_chi_tieu.dart';

class ManHinhThemGiaoDich extends StatefulWidget {
  const ManHinhThemGiaoDich({super.key});

  @override
  State<ManHinhThemGiaoDich> createState() => _ManHinhThemGiaoDichState();
}

class _ManHinhThemGiaoDichState extends State<ManHinhThemGiaoDich> {
  final _formKey = GlobalKey<FormState>();
  String _loai = 'chi';
  String _danhMuc = '';
  double _soTien = 0;
  String _ghiChu = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm giao dịch")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField(
                value: _loai,
                items: const [
                  DropdownMenuItem(value: 'chi', child: Text('Chi tiêu')),
                  DropdownMenuItem(value: 'thu', child: Text('Thu nhập')),
                ],
                decoration: const InputDecoration(labelText: 'Loại giao dịch'),
                onChanged: (value) => setState(() => _loai = value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Danh mục'),
                onChanged: (v) => _danhMuc = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số tiền'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _soTien = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                onChanged: (v) => _ghiChu = v,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_soTien > 0) {
                    final gd = GiaoDich(
                      loai: _loai,
                      danhMuc: _danhMuc,
                      soTien: _soTien,
                      ghiChu: _ghiChu,
                      ngay: DateTime.now(),
                    );
                    Navigator.pop(context, gd);
                  }
                },
                child: const Text("Lưu giao dịch"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
