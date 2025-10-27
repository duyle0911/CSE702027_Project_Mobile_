import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';

class TransactionEntryScreen extends StatefulWidget {
  final String type;
  final String category;

  const TransactionEntryScreen({
    super.key,
    required this.type,
    required this.category,
  });

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final _vnd = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  bool get _isIncome => widget.type == 'income';

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _formatCurrencyOnType(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _amount.value = const TextEditingValue(text: '');
      return;
    }
    final number = double.parse(digits);
    final formatted = _vnd.format(number).replaceAll('₫', '').trim();
    _amount.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final raw = _amount.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    final note = _note.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền phải lớn hơn 0')));
      return;
    }

    context.read<ExpenseModel>().addTransaction(
      type: widget.type,
      amount: amount,
      note: note,
      category: widget.category,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isIncome ? 'Đã lưu khoản thu' : 'Đã lưu khoản chi'} ${_vnd.format(amount)}',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = _isIncome ? Colors.green : Colors.redAccent;
    final icon = _isIncome ? Icons.south_west : Icons.north_east;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_isIncome ? 'Thu nhập' : 'Chi tiêu'} - ${widget.category}',
        ),
        backgroundColor: color,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              title: Text(
                _isIncome ? 'Ghi nhận THU' : 'Ghi nhận CHI',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Danh mục: ${widget.category}'),
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Số tiền',
                          hintText: 'VD: 250.000',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: 'VNĐ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          final raw = (v ?? '').replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          if (raw.isEmpty) return 'Vui lòng nhập số tiền';
                          final d = double.tryParse(raw);
                          if (d == null) return 'Số tiền không hợp lệ';
                          if (d <= 0) return 'Số tiền phải > 0';
                          return null;
                        },
                        onChanged: _formatCurrencyOnType,
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _note,
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú (tuỳ chọn)',
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ngày giao dịch',
                            prefixIcon: const Icon(Icons.event),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}/'
                                '${_selectedDate.month.toString().padLeft(2, '0')}/'
                                '${_selectedDate.year}',
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Lưu giao dịch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50000, 100000, 200000, 500000, 1000000].map((v) {
                final label = _vnd.format(v).replaceAll('₫', '').trim();
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    _amount.text = label;
                    _amount.selection = TextSelection.collapsed(
                      offset: _amount.text.length,
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
