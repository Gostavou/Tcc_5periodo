import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Transaction {
  final String id;
  final String type; // 'expense' ou 'profit'
  final String category;
  final double amount;
  final DateTime date;
  final String note;

  Transaction({
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  }) : id = const Uuid().v4();
}

class ExpenseProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void addTransaction({
    required String type,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
  }) {
    _transactions.add(Transaction(
      type: type,
      category: category,
      amount: amount,
      date: date,
      note: note,
    ));
    notifyListeners();
  }

  double getTotalExpenses() {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (double sum, t) => sum + t.amount);
  }

  double getTotalProfits() {
    return _transactions
        .where((t) => t.type == 'profit')
        .fold(0.0, (double sum, t) => sum + t.amount);
  }

  List<Transaction> getLastTransactions(int count) {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return _transactions.take(count).toList();
  }

  Map<String, double> getExpensesByCategory() {
    Map<String, double> categoryMap = {};
    for (var t in _transactions.where((t) => t.type == 'expense')) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    return categoryMap;
  }

  Map<String, double> getProfitsByCategory() {
    Map<String, double> categoryMap = {};
    for (var t in _transactions.where((t) => t.type == 'profit')) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    return categoryMap;
  }

  // Métodos adicionais para limpar dados (útil para desenvolvimento)
  void clearAllTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  // Método para adicionar dados de exemplo (opcional)
  void addSampleTransactions() {
    final now = DateTime.now();

    // Adiciona despesas de exemplo
    addTransaction(
      type: 'expense',
      category: 'Comida',
      amount: 150.0,
      date: now.subtract(const Duration(days: 2)),
      note: 'Supermercado',
    );

    addTransaction(
      type: 'expense',
      category: 'Lazer',
      amount: 200.0,
      date: now.subtract(const Duration(days: 1)),
      note: 'Cinema',
    );

    // Adiciona receitas de exemplo
    addTransaction(
      type: 'profit',
      category: 'Salário',
      amount: 2500.0,
      date: now,
      note: 'Pagamento mensal',
    );

    addTransaction(
      type: 'profit',
      category: 'Investimentos',
      amount: 150.5,
      date: now.subtract(const Duration(days: 3)),
      note: 'Dividendos',
    );

    notifyListeners();
  }
}
