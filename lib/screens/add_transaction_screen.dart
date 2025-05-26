import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Saúde';

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Saúde',
      'icon': Icons.medical_services,
      'color': Colors.red[400]!,
      'selected': false
    },
    {
      'name': 'Comida',
      'icon': Icons.restaurant,
      'color': Colors.green[400]!,
      'selected': false
    },
    {
      'name': 'Lazer',
      'icon': Icons.sports_esports,
      'color': Colors.blue[400]!,
      'selected': false
    },
    {
      'name': 'Educação',
      'icon': Icons.school,
      'color': Colors.orange[400]!,
      'selected': false
    },
    {
      'name': 'Outros',
      'icon': Icons.more_horiz,
      'color': Colors.purple[400]!,
      'selected': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor',
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
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
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
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .addTransaction(
                    type: 'expense',
                    category: _selectedCategory,
                    amount: amount,
                    date: DateTime.now(),
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
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Adicionar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
