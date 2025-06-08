import 'package:flutter/material.dart';

class InterestCalculatorProvider with ChangeNotifier {
  String _principal = '';
  String _rate = '';
  String _months = '';
  String _monthlyAddition = '';
  bool _includeMonthlyAddition = false;
  List<Map<String, dynamic>> _results = [];
  bool _showResults = false;

  String get principal => _principal;
  String get rate => _rate;
  String get months => _months;
  String get monthlyAddition => _monthlyAddition;
  bool get includeMonthlyAddition => _includeMonthlyAddition;
  List<Map<String, dynamic>> get results => _results;
  bool get showResults => _showResults;

  void setPrincipal(String value) {
    _principal = value;
    notifyListeners();
  }

  void setRate(String value) {
    _rate = value;
    notifyListeners();
  }

  void setMonths(String value) {
    _months = value;
    notifyListeners();
  }

  void setMonthlyAddition(String value) {
    _monthlyAddition = value;
    notifyListeners();
  }

  void toggleMonthlyAddition(bool value) {
    _includeMonthlyAddition = value;
    notifyListeners();
  }

  void calculate() {
    if (_principal.isEmpty || _rate.isEmpty || _months.isEmpty) return;
    if (_includeMonthlyAddition && _monthlyAddition.isEmpty) return;

    final principalValue = double.tryParse(_principal) ?? 0;
    final rateValue = double.tryParse(_rate) ?? 0;
    final monthsValue = int.tryParse(_months) ?? 0;
    final monthlyAdditionValue = double.tryParse(_monthlyAddition) ?? 0;

    _results = [];
    double amount = principalValue;

    for (var month = 1; month <= monthsValue; month++) {
      amount *= (1 + rateValue / 100);
      if (month > 1 && _includeMonthlyAddition) {
        amount += monthlyAdditionValue;
      }

      _results.add({
        'month': month,
        'amount': amount,
        'interest': amount -
            principalValue -
            (month > 1 && _includeMonthlyAddition
                ? monthlyAdditionValue * (month - 1)
                : 0),
      });
    }

    _showResults = true;
    notifyListeners();
  }

  void reset() {
    _principal = '';
    _rate = '';
    _months = '';
    _monthlyAddition = '';
    _includeMonthlyAddition = false;
    _results = [];
    _showResults = false;
    notifyListeners();
  }

  double get finalAmount => _results.isNotEmpty ? _results.last['amount'] : 0;

  double get totalEarnings {
    if (_results.isEmpty) return 0;
    return _results.last['interest'] ?? 0;
  }

  String? validatePrincipal(String? value) {
    if (value == null || value.isEmpty) return 'Insira o valor inicial';
    if (double.tryParse(value) == null) return 'Valor inválido';
    return null;
  }

  String? validateRate(String? value) {
    if (value == null || value.isEmpty) return 'Insira a taxa de juros';
    if (double.tryParse(value) == null) return 'Taxa inválida';
    return null;
  }

  String? validateMonths(String? value) {
    if (value == null || value.isEmpty) return 'Insira o número de meses';
    if (int.tryParse(value) == null) return 'Número inválido';
    return null;
  }

  String? validateMonthlyAddition(String? value) {
    if (_includeMonthlyAddition && (value == null || value.isEmpty)) {
      return 'Insira o valor mensal';
    }
    if (_includeMonthlyAddition && double.tryParse(value ?? '') == null) {
      return 'Valor inválido';
    }
    return null;
  }
}
