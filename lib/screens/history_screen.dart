import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final transactions = expenseProvider.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Transações')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction.category),
            subtitle: Text(transaction.date.toString()),
            trailing: Text(
              'R\$ ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color:
                    transaction.type == 'expense' ? Colors.red : Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
