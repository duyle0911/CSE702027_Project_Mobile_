import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();

  final _categories = const [
    'Ăn uống',
    'Giáo dục',
    'Quần áo',
    'Mua sắm',
    'Giải trí',
    'Đi lại',
    'Hóa đơn',
    'Tiền nhà',
    'Khác',
  ];

  final _vnd = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    final note = _noteController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền phải lớn hơn 0')));
      return;
    }

    context.read<ExpenseModel>().addExpense(amount, note, _selectedCategory);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lưu khoản chi ${_vnd.format(amount)}')),
    );

    Navigator.pop(context);
  }

  void _formatCurrencyOnType(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _amountController.value = TextEditingValue(text: '');
      return;
    }
    final number = double.parse(digits);
    final formatted = _vnd.format(number).replaceAll('₫', '').trim();
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm khoản chi'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Số tiền',
                          hintText: 'VD: 150.000',
                          prefixIcon: const Icon(Icons.money_off),
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
                          if (double.tryParse(raw) == null)
                            return 'Số tiền không hợp lệ';
                          if ((double.tryParse(raw) ?? 0) <= 0)
                            return 'Số tiền phải > 0';
                          return null;
                        },
                        onChanged: _formatCurrencyOnType,
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value!),
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _noteController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú (tuỳ chọn)',
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ngày',
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
                                style: theme.textTheme.bodyLarge,
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Lưu khoản chi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
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

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.take(6).map((c) {
                final selected = c == _selectedCategory;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = c),
                  selectedColor: Colors.redAccent.withOpacity(0.15),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
