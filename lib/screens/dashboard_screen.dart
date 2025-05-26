import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Alteração principal
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';
import 'package:projeto_financeiro/providers/currency_provider.dart';
import 'package:projeto_financeiro/screens/add_transaction_screen.dart';
import 'package:projeto_financeiro/screens/history_screen.dart';
import 'package:projeto_financeiro/screens/settings_screen.dart';
import 'package:projeto_financeiro/screens/currency_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final double totalExpenses = expenseProvider.getTotalExpenses();
    final double totalProfits = expenseProvider.getTotalProfits();
    final Map<String, double> expensesByCategory =
        expenseProvider.getExpensesByCategory();
    final Map<String, double> profitsByCategory =
        expenseProvider.getProfitsByCategory();
    final List<Transaction> lastTransactions =
        expenseProvider.getLastTransactions(5);
    final double saldoFicticio = 5000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context, userProvider),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileCard(userProvider, currencyProvider, saldoFicticio,
                  totalProfits, totalExpenses),
              const SizedBox(height: 20),
              _buildChartsSection(
                  currencyProvider, expensesByCategory, profitsByCategory),
              const SizedBox(height: 20),
              _buildTransactionsSection(currencyProvider, lastTransactions),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, UserProvider userProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userProvider.name),
            accountEmail: Text(userProvider.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: userProvider.photoUrl.isNotEmpty
                  ? NetworkImage(userProvider.photoUrl)
                  : const AssetImage('assets/profile.png') as ImageProvider,
            ),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 74, 133, 201),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag), // Ícone novo
            title: const Text('Metas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/goals');
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Cotações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/currency');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
      UserProvider userProvider,
      CurrencyProvider currencyProvider,
      double saldoFicticio,
      double totalProfits,
      double totalExpenses) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: userProvider.photoUrl.isNotEmpty
                  ? NetworkImage(userProvider.photoUrl)
                  : const AssetImage('assets/profile.png') as ImageProvider,
              radius: 30,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, ${userProvider.name}!',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Saldo: ${currencyProvider.formatCurrency(saldoFicticio + totalProfits - totalExpenses, currencyProvider.currency)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: (saldoFicticio + totalProfits - totalExpenses) >= 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(
      CurrencyProvider currencyProvider,
      Map<String, double> expensesByCategory,
      Map<String, double> profitsByCategory) {
    return SizedBox(
      height: 300,
      child: PageView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: PageController(viewportFraction: 0.9),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildSyncfusionChart(
              'Despesas',
              expensesByCategory,
              currencyProvider,
              isProfit: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildSyncfusionChart(
              'Lucros',
              profitsByCategory,
              currencyProvider,
              isProfit: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncfusionChart(
      String title, Map<String, double> data, CurrencyProvider currencyProvider,
      {bool isProfit = false}) {
    final chartData = data.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();
    final total =
        chartData.fold(0.0, (double sum, _ChartData item) => sum + item.value);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                ),
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.category,
                    yValueMapper: (_ChartData data, _) => data.value,
                    dataLabelMapper: (_ChartData data, _) =>
                        '${currencyProvider.formatCurrency(data.value, currencyProvider.currency)}\n(${(data.value / total * 100).toStringAsFixed(1)}%)',
                    pointColorMapper: (_ChartData data, _) => isProfit
                        ? _getProfitCategoryColor(data.category)
                        : _getCategoryColor(data.category),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        length: '20%',
                      ),
                    ),
                    radius: '80%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: data.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: isProfit
                          ? _getProfitCategoryColor(entry.key)
                          : _getCategoryColor(entry.key),
                    ),
                    const SizedBox(width: 4),
                    Text(
                        '${entry.key}: ${currencyProvider.formatCurrency(entry.value, currencyProvider.currency)}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(
      CurrencyProvider currencyProvider, List<Transaction> transactions) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Últimas Transações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...transactions.map((t) => ListTile(
                  title: Text(t.category),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd/MM/yyyy HH:mm').format(t.date)),
                      if (t.note.isNotEmpty)
                        Text(t.note, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Text(
                    currencyProvider.formatCurrency(
                        t.amount, currencyProvider.currency), // Corrigido aqui
                    style: TextStyle(
                      color: t.type == 'expense' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(
                    t.type == 'expense'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: t.type == 'expense' ? Colors.red : Colors.green,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/add_expense'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Adicionar Despesa',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/add_profit'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.green[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Adicionar Lucro',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Saúde':
        return Colors.red[400]!;
      case 'Comida':
        return Colors.green[400]!;
      case 'Lazer':
        return Colors.blue[400]!;
      case 'Educação':
        return Colors.orange[400]!;
      default:
        return Colors.purple[400]!;
    }
  }

  Color _getProfitCategoryColor(String category) {
    switch (category) {
      case 'Salário':
        return Colors.blue[800]!;
      case 'Investimentos':
        return Colors.green[800]!;
      case 'Presente':
        return Colors.purple[800]!;
      default:
        return Colors.orange[800]!;
    }
  }
}

class _ChartData {
  final String category;
  final double value;

  _ChartData(this.category, this.value);
}
