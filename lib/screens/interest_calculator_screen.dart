import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/interest_calculator_provider.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';

class InterestCalculatorScreen extends StatelessWidget {
  const InterestCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InterestCalculatorProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculadora de Juros Compostos'),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: _buildCustomDrawer(context),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF5F7FA),
                Color(0xFFE4E7EB),
              ],
            ),
          ),
          child: const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: CalculatorForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[600]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              accountName: Text(userProvider.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              accountEmail: Text(userProvider.email,
                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userProvider.photoUrl.isNotEmpty
                    ? NetworkImage(userProvider.photoUrl)
                    : null,
                child: userProvider.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.blue)
                    : null,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(context, Icons.home, 'Início', '/dashboard'),
                  _buildDrawerItem(context, Icons.flag, 'Metas', '/goals'),
                  _buildDrawerItem(context, Icons.currency_exchange, 'Cotações',
                      '/currency'),
                  _buildDrawerItem(context, Icons.calculate,
                      'Calculadora de Juros', '/interest_calculator'),
                  _buildDrawerItem(
                      context, Icons.history, 'Histórico', '/history'),
                  _buildDrawerItem(
                      context, Icons.settings, 'Configurações', '/settings'),
                ],
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1),
            _buildDrawerItem(context, Icons.logout, 'Sair', '/login',
                isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String routeName,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isLogout ? Colors.red[200] : Colors.white.withOpacity(0.9)),
      title: Text(title,
          style: TextStyle(
              color: isLogout ? Colors.red[200] : Colors.white, fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          Provider.of<UserProvider>(context, listen: false).clearUser();
          Navigator.pushReplacementNamed(context, routeName);
        } else {
          Navigator.pushNamed(context, routeName);
        }
      },
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }
}

class CalculatorForm extends StatefulWidget {
  const CalculatorForm({super.key});

  @override
  State<CalculatorForm> createState() => _CalculatorFormState();
}

class _CalculatorFormState extends State<CalculatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _monthsController = TextEditingController();
  final _monthlyAdditionController = TextEditingController();

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    _monthlyAdditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InterestCalculatorProvider>(context);
    final currencyFormat = NumberFormat.currency(
      symbol: 'R\$',
      decimalDigits: 2,
      locale: 'pt_BR',
    );
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildInputField(
                    context,
                    controller: _principalController,
                    label: 'Valor Inicial',
                    icon: Icons.attach_money,
                    onChanged: provider.setPrincipal,
                    validator: provider.validatePrincipal,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    context,
                    controller: _rateController,
                    label: 'Taxa de Juros Mensal (%)',
                    icon: Icons.percent,
                    onChanged: provider.setRate,
                    validator: provider.validateRate,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    context,
                    controller: _monthsController,
                    label: 'Número de Meses',
                    icon: Icons.calendar_today,
                    onChanged: provider.setMonths,
                    validator: provider.validateMonths,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      'Adicionar valor mensal?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: provider.includeMonthlyAddition,
                    onChanged: (value) {
                      provider.toggleMonthlyAddition(value);
                      if (!value) {
                        _monthlyAdditionController.clear();
                        provider.setMonthlyAddition('');
                      }
                    },
                    activeColor: Colors.blue.shade800,
                    inactiveTrackColor: Colors.grey.shade400,
                  ),
                  if (provider.includeMonthlyAddition) ...[
                    const SizedBox(height: 8),
                    _buildInputField(
                      context,
                      controller: _monthlyAdditionController,
                      label: 'Valor Mensal Adicional',
                      icon: Icons.add_circle_outline,
                      onChanged: provider.setMonthlyAddition,
                      validator: provider.validateMonthlyAddition,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calculate,
                      size: 24, color: Colors.white),
                  label: const Text(
                    'CALCULAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      provider.calculate();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.refresh,
                      size: 24, color: Colors.blue.shade800),
                  label: Text(
                    'LIMPAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  onPressed: () {
                    _formKey.currentState?.reset();
                    _principalController.clear();
                    _rateController.clear();
                    _monthsController.clear();
                    _monthlyAdditionController.clear();
                    provider.reset();
                    FocusScope.of(context).unfocus();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.blue.shade800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (provider.showResults) ...[
            _buildResultsSection(provider, currencyFormat, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildResultsSection(
    InterestCalculatorProvider provider,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'RESULTADOS',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryRow(
                    'Valor Inicial:',
                    currencyFormat
                        .format(double.tryParse(provider.principal) ?? 0)),
                if (provider.includeMonthlyAddition)
                  _buildSummaryRow(
                      'Adição Mensal:',
                      currencyFormat.format(
                          double.tryParse(provider.monthlyAddition) ?? 0)),
                _buildSummaryRow('Taxa Mensal:', '${provider.rate}%'),
                const Divider(height: 24, thickness: 1),
                _buildSummaryRow('Período:', '${provider.months} meses',
                    isBold: true),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Total Investido:',
                  currencyFormat.format(
                    (double.tryParse(provider.principal) ?? 0) +
                        (provider.includeMonthlyAddition
                            ? (double.tryParse(provider.monthlyAddition) ?? 0) *
                                (int.tryParse(provider.months) ?? 0)
                            : 0),
                  ),
                  isBold: true,
                ),
                _buildSummaryRow('Total Acumulado:',
                    currencyFormat.format(provider.finalAmount),
                    isBold: true, isAccent: true),
                _buildSummaryRow('Rendimento:',
                    currencyFormat.format(provider.totalEarnings),
                    isBold: true, isPositive: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progresso Mensal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: provider.results.length,
                    itemBuilder: (context, index) {
                      final result = provider.results[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  '${result['month']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Mês ${result['month']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: (result['amount'] /
                                            provider.finalAmount)
                                        .clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey.shade200,
                                    color: Colors.blue.shade600,
                                    minHeight: 6,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Juros: ${currencyFormat.format(result['interest'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                currencyFormat.format(result['amount']),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade800,
                                ),
                              ),
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
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isAccent = false,
    bool isPositive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isAccent
                  ? Colors.blue.shade800
                  : isPositive
                      ? Colors.green.shade800
                      : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
