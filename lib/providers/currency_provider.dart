import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CurrencyProvider with ChangeNotifier {
  String _currency = 'BRL';
  String get currency => _currency;

  Map<String, dynamic> _exchangeRates = {};
  Map<String, dynamic> get exchangeRates => _exchangeRates;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _supportedCurrencies = [
    {'code': 'BRL', 'name': 'Real Brasileiro', 'symbol': 'R\$', 'flag': '🇧🇷'},
    {'code': 'USD', 'name': 'Dólar Americano', 'flag': '🇺🇸', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺', 'symbol': '€'},
    {'code': 'GBP', 'name': 'Libra Esterlina', 'flag': '🇬🇧', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Iene Japonês', 'flag': '🇯🇵', 'symbol': '¥'},
    {'code': 'CAD', 'name': 'Dólar Canadense', 'flag': '🇨🇦', 'symbol': 'C\$'},
    {
      'code': 'AUD',
      'name': 'Dólar Australiano',
      'flag': '🇦🇺',
      'symbol': 'A\$'
    },
    {'code': 'CHF', 'name': 'Franco Suíço', 'flag': '🇨🇭', 'symbol': 'CHF'},
    {'code': 'CNY', 'name': 'Yuan Chinês', 'flag': '🇨🇳', 'symbol': '¥'},
    {'code': 'ARS', 'name': 'Peso Argentino', 'flag': '🇦🇷', 'symbol': '\$'},
    {'code': 'MXN', 'name': 'Peso Mexicano', 'flag': '🇲🇽', 'symbol': '\$'},
  ];

  List<Map<String, dynamic>> get supportedCurrencies => _supportedCurrencies;

  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    notifyListeners();
  }

  Future<void> fetchExchangeRates() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
            'https://v6.exchangerate-api.com/v6/aecd5cb8847ac985a93792c9/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          _processExchangeRates(data);
        } else {
          _errorMessage = data['error-type'] ?? 'Erro na API';
          _setDefaultRates();
        }
      } else {
        _errorMessage = 'Erro HTTP: ${response.statusCode}';
        _setDefaultRates();
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _setDefaultRates();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processExchangeRates(Map<String, dynamic> data) {
    final usdRates = data['conversion_rates'];
    final brlRate = usdRates['BRL'];

    _exchangeRates = {
      'USD': {'rate': 1 / brlRate, 'converted': 10 / brlRate},
      'EUR': {
        'rate': usdRates['EUR'] / brlRate,
        'converted': 10 * usdRates['EUR'] / brlRate
      },
      'GBP': {
        'rate': usdRates['GBP'] / brlRate,
        'converted': 10 * usdRates['GBP'] / brlRate
      },
      'JPY': {
        'rate': usdRates['JPY'] / brlRate,
        'converted': 10 * usdRates['JPY'] / brlRate
      },
      'CAD': {
        'rate': usdRates['CAD'] / brlRate,
        'converted': 10 * usdRates['CAD'] / brlRate
      },
      'AUD': {
        'rate': usdRates['AUD'] / brlRate,
        'converted': 10 * usdRates['AUD'] / brlRate
      },
      'CHF': {
        'rate': usdRates['CHF'] / brlRate,
        'converted': 10 * usdRates['CHF'] / brlRate
      },
      'CNY': {
        'rate': usdRates['CNY'] / brlRate,
        'converted': 10 * usdRates['CNY'] / brlRate
      },
      'ARS': {
        'rate': usdRates['ARS'] / brlRate,
        'converted': 10 * usdRates['ARS'] / brlRate
      },
      'MXN': {
        'rate': usdRates['MXN'] / brlRate,
        'converted': 10 * usdRates['MXN'] / brlRate
      },
      'BRL': {'rate': 1.0, 'converted': 10.0},
    };
  }

  void _setDefaultRates() {
    _exchangeRates = {
      'USD': {'rate': 0.19, 'converted': 1.92},
      'EUR': {'rate': 0.17, 'converted': 1.72},
      'GBP': {'rate': 0.15, 'converted': 1.50},
      'JPY': {'rate': 25.0, 'converted': 250.0},
      'CAD': {'rate': 0.24, 'converted': 2.40},
      'AUD': {'rate': 0.28, 'converted': 2.80},
      'CHF': {'rate': 0.17, 'converted': 1.70},
      'CNY': {'rate': 1.35, 'converted': 13.50},
      'ARS': {'rate': 180.0, 'converted': 1800.0},
      'MXN': {'rate': 35.0, 'converted': 350.0},
      'BRL': {'rate': 1.0, 'converted': 10.0},
    };
  }

  String formatCurrency(double value, String currencyCode) {
    final currency = _supportedCurrencies.firstWhere(
      (c) => c['code'] == currencyCode,
      orElse: () => {'symbol': '\$'},
    );
    return '${currency['symbol']} ${value.toStringAsFixed(2)}';
  }

  double convertCurrency(
      double amount, String fromCurrency, String toCurrency) {
    if (_exchangeRates.isEmpty) return 0.0;

    if (fromCurrency == 'BRL') {
      return amount * (_exchangeRates[toCurrency]?['rate'] ?? 0);
    }

    if (toCurrency == 'BRL') {
      return amount / (_exchangeRates[fromCurrency]?['rate'] ?? 1);
    }

    return (amount * _exchangeRates[fromCurrency]!['rate']!) /
        _exchangeRates[toCurrency]!['rate']!;
  }

  void clearCurrencyData() {
    _currency = 'BRL';
    _exchangeRates = {};
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
