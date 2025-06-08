import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';
import 'package:intl/intl.dart';
import 'package:projeto_financeiro/models/transaction_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterType = 'all';
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    var transactions = expenseProvider.transactions;

    if (_filterType != 'all') {
      transactions = transactions.where((t) => t.type == _filterType).toList();
    }

    transactions.sort((a, b) {
      if (_sortBy == 'date') {
        return _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date);
      } else {
        return _sortAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Receitas',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${_calculateTotal(transactions, 'profit').toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Despesas',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${_calculateTotal(transactions, 'expense').toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Saldo',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${_calculateBalance(transactions).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma transação encontrada',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_filterType != 'all')
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _filterType = 'all';
                                });
                              },
                              child: const Text('Limpar filtros'),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final isExpense = transaction.type == 'expense';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isExpense
                                                  ? Colors.red.shade50
                                                  : Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              isExpense
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              color: isExpense
                                                  ? Colors.red
                                                  : Colors.green,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                transaction.category,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('dd/MM/yyyy - HH:mm')
                                                    .format(transaction.date),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'R\$ ${transaction.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isExpense
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (transaction.note.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 42),
                                      child: Text(
                                        transaction.note,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(List<TransactionModel> transactions, String type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _calculateBalance(List<TransactionModel> transactions) {
    final income = _calculateTotal(transactions, 'profit');
    final expense = _calculateTotal(transactions, 'expense');
    return income - expense;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar e Ordenar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar por tipo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                title: const Text('Todas'),
                value: 'all',
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() {
                    _filterType = value.toString();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text('Receitas',
                    style: TextStyle(color: Colors.green.shade700)),
                value: 'profit',
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() {
                    _filterType = value.toString();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text('Despesas',
                    style: TextStyle(color: Colors.red.shade700)),
                value: 'expense',
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() {
                    _filterType = value.toString();
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Text(
                'Ordenar por:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                title: const Text('Data'),
                value: 'date',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value.toString();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text('Valor'),
                value: 'amount',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value.toString();
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Text(
                'Ordem:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                title: Text(_sortBy == 'date'
                    ? 'Mais antigo primeiro'
                    : 'Menor valor primeiro'),
                value: true,
                groupValue: _sortAscending,
                onChanged: (value) {
                  setState(() {
                    _sortAscending = value as bool;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text(_sortBy == 'date'
                    ? 'Mais recente primeiro'
                    : 'Maior valor primeiro'),
                value: false,
                groupValue: _sortAscending,
                onChanged: (value) {
                  setState(() {
                    _sortAscending = value as bool;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
