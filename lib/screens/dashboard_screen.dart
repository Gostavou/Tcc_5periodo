import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';
import 'package:projeto_financeiro/providers/currency_provider.dart';
import 'package:projeto_financeiro/models/transaction_model.dart';
import 'package:projeto_financeiro/screens/add_transaction_screen.dart';
import 'package:projeto_financeiro/screens/history_screen.dart';
import 'package:projeto_financeiro/screens/settings_screen.dart';
import 'package:projeto_financeiro/screens/currency_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimePeriod = 'Mês';
  late DateTime _selectedDate = DateTime.now();
  String _selectedChartType = 'Despesas';
  Set<String> _selectedCategories = {};

  final Map<String, int> _timePeriods = {
    'Dia': 1,
    'Semana': 7,
    'Mês': 30,
    'Ano': 365,
  };

  final Map<String, Color> _categoryColors = {
    // Aqui pra baixo despesas/gastos, ainda vou aumentar a quantidade de categoria
    'Comida': Colors.green[400]!,
    'Saúde': Colors.red[400]!,
    'Lazer': Colors.blue[400]!,
    'Educação': Colors.orange[400]!,
    'Outros (Despesas)': Colors.purple[400]!,
    // Aqui pra baixo receitas/lucro
    'Salário': Colors.blue[600]!,
    'Investimento': Colors.green[600]!,
    'Presente': Colors.purple[600]!,
    'Outros (Receitas)': Colors.orange[600]!,
  };

  final Map<String, String> _categoryMapping = {
    'Alimentação': 'Comida',
    'Transporte': 'Outros (Despesas)',
    'Moradia': 'Outros (Despesas)',
    'Saúde': 'Saúde',
    'Lazer': 'Lazer',
    'Educação': 'Educação',
    'Outros': 'Outros (Despesas)',
    'Salário': 'Salário',
    'Investimentos': 'Investimento',
    'Presente': 'Presente',
    'Vendas': 'Outros (Receitas)',
  };

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    final filteredTransactions = expenseProvider.getTransactionsByPeriod(
      _selectedDate,
      _timePeriods[_selectedTimePeriod]!,
    );

    final double totalExpenses = expenseProvider.getTotalExpensesByPeriod(
        filteredTransactions.where((t) => t.type == 'expense').toList());
    final double totalProfits = expenseProvider.getTotalProfitsByPeriod(
        filteredTransactions.where((t) => t.type == 'profit').toList());

    final Map<String, double> expensesByCategory =
        expenseProvider.getExpensesByCategory(filteredTransactions);
    final Map<String, double> profitsByCategory =
        expenseProvider.getProfitsByCategory(filteredTransactions);
    final List<TransactionModel> lastTransactions =
        expenseProvider.getLastTransactions(5);
    final double saldoFicticio = 5000;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
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
      drawer: _buildCustomDrawer(context, userProvider),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTimePeriodSelector(),
                const SizedBox(height: 10),
                _buildProfileCard(userProvider, currencyProvider, saldoFicticio,
                    totalProfits, totalExpenses),
                const SizedBox(height: 20),
                _buildFinancialAnalysisSection(
                    currencyProvider, expensesByCategory, profitsByCategory),
                const SizedBox(height: 20),
                _buildTransactionsSection(currencyProvider, lastTransactions),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context, UserProvider userProvider) {
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

  Widget _buildTimePeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.blue[800]),
              onPressed: () {
                setState(() {
                  if (_selectedTimePeriod == 'Dia') {
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 1));
                  } else if (_selectedTimePeriod == 'Semana') {
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 7));
                  } else if (_selectedTimePeriod == 'Mês') {
                    _selectedDate = DateTime(_selectedDate.year,
                        _selectedDate.month - 1, _selectedDate.day);
                  } else if (_selectedTimePeriod == 'Ano') {
                    _selectedDate = DateTime(_selectedDate.year - 1,
                        _selectedDate.month, _selectedDate.day);
                  }
                });
              },
            ),
            DropdownButton<String>(
              value: _selectedTimePeriod,
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[800]),
              elevation: 16,
              style: TextStyle(
                  color: Colors.blue[800], fontWeight: FontWeight.bold),
              underline: Container(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimePeriod = newValue!;
                  _selectedDate = DateTime.now();
                });
              },
              items: _timePeriods.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Text(
              _getFormattedDateRange(),
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.blue[800]),
              onPressed: () {
                setState(() {
                  if (_selectedTimePeriod == 'Dia') {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  } else if (_selectedTimePeriod == 'Semana') {
                    _selectedDate = _selectedDate.add(const Duration(days: 7));
                  } else if (_selectedTimePeriod == 'Mês') {
                    _selectedDate = DateTime(_selectedDate.year,
                        _selectedDate.month + 1, _selectedDate.day);
                  } else if (_selectedTimePeriod == 'Ano') {
                    _selectedDate = DateTime(_selectedDate.year + 1,
                        _selectedDate.month, _selectedDate.day);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDateRange() {
    final formatter = DateFormat('dd/MM/yyyy');
    if (_selectedTimePeriod == 'Dia') {
      return formatter.format(_selectedDate);
    } else if (_selectedTimePeriod == 'Semana') {
      final endDate = _selectedDate.add(const Duration(days: 6));
      return '${formatter.format(_selectedDate)} - ${formatter.format(endDate)}';
    } else if (_selectedTimePeriod == 'Mês') {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    } else {
      return _selectedDate.year.toString();
    }
  }

  Widget _buildProfileCard(
    UserProvider userProvider,
    CurrencyProvider currencyProvider,
    double saldoFicticio,
    double totalProfits,
    double totalExpenses,
  ) {
    final balance = saldoFicticio + totalProfits - totalExpenses;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: balance >= 0
              ? [Colors.green[600]!, Colors.green[400]!]
              : [Colors.red[600]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userProvider.photoUrl.isNotEmpty
                    ? NetworkImage(userProvider.photoUrl)
                    : null,
                child: userProvider.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.blue)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo, ${userProvider.name}!',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saldo Atual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    currencyProvider.formatCurrency(
                        balance, currencyProvider.currency),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Período: $_selectedTimePeriod',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildMiniInfoCard(
                  'Receitas',
                  totalProfits,
                  currencyProvider,
                  Colors.green[100]!,
                  Colors.green[800]!,
                ),
                const SizedBox(height: 8),
                _buildMiniInfoCard(
                  'Despesas',
                  totalExpenses,
                  currencyProvider,
                  Colors.red[100]!,
                  Colors.red[800]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfoCard(String title, double value,
      CurrencyProvider currencyProvider, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            currencyProvider.formatCurrency(value, currencyProvider.currency),
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialAnalysisSection(
    CurrencyProvider currencyProvider,
    Map<String, double> expensesByCategory,
    Map<String, double> profitsByCategory,
  ) {
    final data = _selectedChartType == 'Despesas'
        ? _mapCategories(expensesByCategory)
        : _mapCategories(profitsByCategory);

    final filteredData = Map.fromEntries(data.entries.where(
      (entry) => !_selectedCategories.contains(entry.key),
    ));

    final total = filteredData.values.fold(0.0, (sum, value) => sum + value);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Análise Financeira',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: _selectedChartType,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue[800]),
                  elevation: 0,
                  style: TextStyle(
                      color: Colors.blue[800], fontWeight: FontWeight.w500),
                  underline: Container(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedChartType = newValue!;
                      _selectedCategories = {};
                    });
                  },
                  items: ['Despesas', 'Receitas']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: _selectedChartType == 'Despesas'
                      ? _buildExpensesChart(
                          currencyProvider, filteredData, total)
                      : _buildProfitsChart(
                          currencyProvider, filteredData, total),
                ),
                const SizedBox(height: 16),
                _buildCategoryList(data, currencyProvider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesChart(
    CurrencyProvider currencyProvider,
    Map<String, double> filteredData,
    double total,
  ) {
    final chartData = filteredData.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return SfCircularChart(
      margin: EdgeInsets.zero,
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Despesas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyProvider.formatCurrency(
                    total, currencyProvider.currency),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
        )
      ],
      series: <CircularSeries>[
        DoughnutSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.category,
          yValueMapper: (_ChartData data, _) => data.value,
          pointColorMapper: (_ChartData data, _) =>
              _getCategoryColor(data.category, isExpense: true),
          dataLabelMapper: (_ChartData data, _) =>
              '${(data.value / total * 100).toStringAsFixed(1)}%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 12),
            connectorLineSettings: ConnectorLineSettings(
              length: '20%',
              width: 2,
            ),
          ),
          radius: '70%',
          innerRadius: '60%',
          selectionBehavior: SelectionBehavior(
            enable: true,
            selectedColor: Colors.grey.withOpacity(0.3),
            toggleSelection: true,
          ),
          onPointTap: (ChartPointDetails details) {
            setState(() {
              final category = details.pointIndex != null
                  ? chartData[details.pointIndex!].category
                  : '';
              if (_selectedCategories.contains(category)) {
                _selectedCategories.remove(category);
              } else {
                _selectedCategories.add(category);
              }
            });
          },
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildProfitsChart(
    CurrencyProvider currencyProvider,
    Map<String, double> filteredData,
    double total,
  ) {
    final chartData = filteredData.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return SfCircularChart(
      margin: EdgeInsets.zero,
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Receitas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyProvider.formatCurrency(
                    total, currencyProvider.currency),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[400],
                ),
              ),
            ],
          ),
        )
      ],
      series: <CircularSeries>[
        DoughnutSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.category,
          yValueMapper: (_ChartData data, _) => data.value,
          pointColorMapper: (_ChartData data, _) =>
              _getCategoryColor(data.category, isExpense: false),
          dataLabelMapper: (_ChartData data, _) =>
              '${(data.value / total * 100).toStringAsFixed(1)}%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 12),
            connectorLineSettings: ConnectorLineSettings(
              length: '20%',
              width: 2,
            ),
          ),
          radius: '70%',
          innerRadius: '60%',
          selectionBehavior: SelectionBehavior(
            enable: true,
            selectedColor: Colors.grey.withOpacity(0.3),
            toggleSelection: true,
          ),
          onPointTap: (ChartPointDetails details) {
            setState(() {
              final category = details.pointIndex != null
                  ? chartData[details.pointIndex!].category
                  : '';
              if (_selectedCategories.contains(category)) {
                _selectedCategories.remove(category);
              } else {
                _selectedCategories.add(category);
              }
            });
          },
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildCategoryList(
    Map<String, double> data,
    CurrencyProvider currencyProvider,
  ) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    final isExpense = _selectedChartType == 'Despesas';

    return SizedBox(
      height: 120,
      child: ListView(
        children: data.entries.map((entry) {
          final percentage = (entry.value / total * 100).toStringAsFixed(1);
          final categoryColor =
              _getCategoryColor(entry.key, isExpense: isExpense);
          final isSelected = _selectedCategories.contains(entry.key);

          return InkWell(
            onTap: () {
              setState(() {
                if (_selectedCategories.contains(entry.key)) {
                  _selectedCategories.remove(entry.key);
                } else {
                  _selectedCategories.add(entry.key);
                }
              });
            },
            child: Opacity(
              opacity: isSelected ? 0.5 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.grey : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${currencyProvider.formatCurrency(entry.value, currencyProvider.currency)} ($percentage%)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, double> _mapCategories(Map<String, double> originalCategories) {
    final mappedCategories = <String, double>{};

    originalCategories.forEach((key, value) {
      final mappedKey = _categoryMapping[key] ?? key;
      mappedCategories[mappedKey] = (mappedCategories[mappedKey] ?? 0) + value;
    });

    return mappedCategories;
  }

  Color _getCategoryColor(String category, {required bool isExpense}) {
    return _categoryColors[category] ??
        (isExpense ? Colors.grey[400]! : Colors.grey[600]!);
  }

  Widget _buildTransactionsSection(
    CurrencyProvider currencyProvider,
    List<TransactionModel> transactions,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimas Transações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Ver Tudo',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...transactions.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[50],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.type == 'expense'
                            ? Colors.red[50]
                            : Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        t.type == 'expense'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: t.type == 'expense' ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      t.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy • HH:mm').format(t.date),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (t.note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              t.note,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyProvider.formatCurrency(
                              t.amount, currencyProvider.currency),
                          style: TextStyle(
                            color:
                                t.type == 'expense' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          t.type == 'expense' ? 'Despesa' : 'Receita',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add_expense'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Nova Despesa',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add_profit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Nova Receita',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  final String category;
  final double value;

  _ChartData(this.category, this.value);
}
