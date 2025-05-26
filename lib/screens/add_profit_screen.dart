import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';

class AddProfitScreen extends StatefulWidget {
  const AddProfitScreen({super.key});

  @override
  State<AddProfitScreen> createState() => _AddProfitScreenState();
}

class _AddProfitScreenState extends State<AddProfitScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Salário';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Salário',
      'icon': Icons.work,
      'color': Colors.blue[800]!,
    },
    {
      'name': 'Investimentos',
      'icon': Icons.trending_up,
      'color': Colors.green[800]!,
    },
    {
      'name': 'Presente',
      'icon': Icons.card_giftcard,
      'color': Colors.purple[800]!,
    },
    {
      'name': 'Outros',
      'icon': Icons.more_horiz,
      'color': Colors.orange[800]!,
    },
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Receita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ChoiceChip(
                      label: Text(category['name']),
                      selected: _selectedCategory == category['name'],
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category['name'];
                        });
                      },
                      avatar: Icon(category['icon'], color: category['color']),
                      selectedColor: category['color'].withOpacity(0.2),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: _selectedCategory == category['name']
                            ? category['color']
                            : Colors.black,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child:
                          Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Observação (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    final dateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );

                    Provider.of<ExpenseProvider>(context, listen: false)
                        .addTransaction(
                      type: 'profit',
                      category: _selectedCategory,
                      amount: amount,
                      date: dateTime,
                      note: _noteController.text,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, insira um valor válido.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green[800],
                ),
                child: const Text(
                  'Adicionar Receita',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
