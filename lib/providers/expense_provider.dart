import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:projeto_financeiro/services/database_service.dart';
import 'package:projeto_financeiro/models/transaction_model.dart';

class ExpenseProvider with ChangeNotifier {
  late DatabaseService _databaseService;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  ExpenseProvider({required DatabaseService databaseService}) {
    _databaseService = databaseService;
    _loadInitialData();
  }

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadInitialData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _databaseService.getTransactions().listen((transactions) {
        _transactions = transactions;
        _isLoading = false;
        _error = null;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Erro ao carregar transações';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TransactionModel> getTransactionsByPeriod(DateTime date, int daysBack) {
    final normalizedEnd =
        DateTime(date.year, date.month, date.day).add(const Duration(days: 1));
    final normalizedStart = normalizedEnd.subtract(Duration(days: daysBack));

    return _transactions.where((transaction) {
      final tDate = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      return tDate.isAtSameMomentAs(normalizedStart) ||
          (tDate.isAfter(normalizedStart) && tDate.isBefore(normalizedEnd));
    }).toList();
  }

  double getTotalExpensesByPeriod(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalProfitsByPeriod(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'profit')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getExpensesByCategory(
      List<TransactionModel> transactions) {
    final categoryMap = <String, double>{};
    for (final t in transactions.where((t) => t.type == 'expense')) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    return categoryMap;
  }

  Map<String, double> getProfitsByCategory(
      List<TransactionModel> transactions) {
    final categoryMap = <String, double>{};
    for (final t in transactions.where((t) => t.type == 'profit')) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }
    return categoryMap;
  }

  void updateDatabaseService(DatabaseService databaseService) {
    _databaseService = databaseService;
    _loadInitialData();
  }

  Future<void> addTransaction({
    required String type,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        type: type,
        category: category,
        amount: amount,
        date: date,
        note: note,
      );

      await _databaseService.saveTransaction(transaction);
      _error = null;
    } catch (e) {
      _error = 'Erro ao adicionar transação';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.deleteTransaction(transactionId);
      _error = null;
    } catch (e) {
      _error = 'Erro ao remover transação';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double getTotalExpenses() {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalProfits() {
    return _transactions
        .where((t) => t.type == 'profit')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<TransactionModel> getLastTransactions(int count) {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return _transactions.take(count).toList();
  }

  Future<void> addSampleTransactions() async {
    try {
      final now = DateTime.now();

      await addTransaction(
        type: 'expense',
        category: 'Comida',
        amount: 150.0,
        date: now.subtract(const Duration(days: 2)),
        note: 'Supermercado',
      );

      await addTransaction(
        type: 'expense',
        category: 'Lazer',
        amount: 200.0,
        date: now.subtract(const Duration(days: 1)),
        note: 'Cinema',
      );

      await addTransaction(
        type: 'profit',
        category: 'Salário',
        amount: 2500.0,
        date: now,
        note: 'Pagamento mensal',
      );

      await addTransaction(
        type: 'profit',
        category: 'Investimentos',
        amount: 150.5,
        date: now.subtract(const Duration(days: 3)),
        note: 'Dividendos',
      );
    } catch (e) {
      _error = 'Erro ao adicionar transações de exemplo';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
