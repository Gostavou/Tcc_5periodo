import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/currency_provider.dart';
import 'package:intl/intl.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'BRL';
  String _toCurrency = 'USD';
  double _convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.text = '10.00';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrencyProvider>(context, listen: false)
          .fetchExchangeRates();
    });
  }

  void _convertCurrency() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final provider = Provider.of<CurrencyProvider>(context, listen: false);

    setState(() {
      _convertedAmount =
          provider.convertCurrency(amount, _fromCurrency, _toCurrency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: currencyProvider.fetchExchangeRates,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card de cotações
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Cotações de 10 Reais (BRL)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (currencyProvider.isLoading)
                        const CircularProgressIndicator()
                      else if (currencyProvider.errorMessage.isNotEmpty)
                        Text(
                          currencyProvider.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        )
                      else
                        _buildExchangeRatesList(currencyProvider),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Card de conversão
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Conversor de Moedas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Campo de valor
                      TextField(
                        controller: _amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Valor em Reais',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        onChanged: (_) => _convertCurrency(),
                      ),

                      const SizedBox(height: 15),

                      // Seletores de moeda
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencyDropdown(
                              value: _fromCurrency,
                              onChanged: (value) {
                                setState(() => _fromCurrency = value!);
                                _convertCurrency();
                              },
                              label: 'De',
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCurrencyDropdown(
                              value: _toCurrency,
                              onChanged: (value) {
                                setState(() => _toCurrency = value!);
                                _convertCurrency();
                              },
                              label: 'Para',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Resultado da conversão
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_amountController.text} BRL =',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currencyProvider.formatCurrency(
                                  _convertedAmount, _toCurrency),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeRatesList(CurrencyProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.supportedCurrencies.length,
      itemBuilder: (context, index) {
        final currency = provider.supportedCurrencies[index];
        final rateInfo =
            provider.exchangeRates[currency['code']] ?? {'converted': 0.0};

        return ListTile(
          leading: Text(
            currency['flag'],
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(currency['name']),
          subtitle: Text(currency['code']),
          trailing: Text(
            provider.formatCurrency(rateInfo['converted'], currency['code']),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    final provider = Provider.of<CurrencyProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          items: [
            DropdownMenuItem(
              value: 'BRL',
              child: Row(
                children: [
                  const Text('🇧🇷', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  const Text('Real Brasileiro (BRL)'),
                ],
              ),
            ),
            ...provider.supportedCurrencies.map((currency) {
              return DropdownMenuItem(
                value: currency['code'],
                child: Row(
                  children: [
                    Text(currency['flag'],
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text('${currency['name']} (${currency['code']})'),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ],
    );
  }
}
