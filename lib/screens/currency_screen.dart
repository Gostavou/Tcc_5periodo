import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/currency_provider.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';

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

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convertCurrency();
    });
  }

  Widget _buildDrawer(BuildContext context, UserProvider userProvider) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[600]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
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
                    : const AssetImage('assets/profile.png') as ImageProvider,
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
          Navigator.pushReplacementNamed(context, routeName);
        } else {
          Navigator.pushNamed(context, routeName);
        }
      },
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildSwapButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: animation,
            child: child,
          ),
          child: const Icon(
            Icons.swap_horiz,
            key: ValueKey('swap_icon'),
          ),
        ),
        color: theme.colorScheme.onPrimary,
        onPressed: _swapCurrencies,
        splashRadius: 24,
        tooltip: 'Inverter moedas',
      ),
    );
  }

  Widget _buildExchangeRatesList(CurrencyProvider provider, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.supportedCurrencies.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: theme.colorScheme.outline.withOpacity(0.1),
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final currency = provider.supportedCurrencies[index];
            final rateInfo =
                provider.exchangeRates[currency['code']] ?? {'converted': 0.0};

            return Container(
              decoration: BoxDecoration(
                color: index.isEven
                    ? theme.colorScheme.surfaceVariant.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    currency['flag'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                title: Text(
                  currency['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  currency['code'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    provider.formatCurrency(
                        rateInfo['converted'], currency['code']),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required String label,
    required ThemeData theme,
  }) {
    final provider = Provider.of<CurrencyProvider>(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceVariant.withOpacity(0.3),
                theme.colorScheme.surfaceVariant.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: value,
            dropdownColor: theme.colorScheme.surface,
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              size: 28,
            ),
            items: [
              DropdownMenuItem<String>(
                value: 'BRL',
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🇧🇷', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Text(isSmallScreen ? 'BRL' : 'Real Brasileiro',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              ...provider.supportedCurrencies
                  .map<DropdownMenuItem<String>>((currency) {
                final String code = currency['code'] as String;
                final String name = currency['name'] as String;
                final String flag = currency['flag'] as String;

                return DropdownMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        alignment: Alignment.center,
                        child: Text(flag, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          isSmallScreen ? code : name,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: Colors.transparent,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    double getConversionRate() {
      if (_fromCurrency == 'BRL' &&
          currencyProvider.exchangeRates.containsKey(_toCurrency)) {
        return currencyProvider.exchangeRates[_toCurrency]!['rate'] ?? 1.0;
      } else if (_toCurrency == 'BRL' &&
          currencyProvider.exchangeRates.containsKey(_fromCurrency)) {
        return 1 /
            (currencyProvider.exchangeRates[_fromCurrency]!['rate'] ?? 1.0);
      } else if (currencyProvider.exchangeRates.containsKey(_fromCurrency) &&
          currencyProvider.exchangeRates.containsKey(_toCurrency)) {
        final fromRate = _fromCurrency == 'BRL'
            ? 1.0
            : currencyProvider.exchangeRates[_fromCurrency]!['rate'] ?? 1.0;
        final toRate = _toCurrency == 'BRL'
            ? 1.0
            : currencyProvider.exchangeRates[_toCurrency]!['rate'] ?? 1.0;
        return toRate / fromRate;
      }
      return 1.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: currencyProvider.fetchExchangeRates,
              tooltip: 'Atualizar cotações',
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, userProvider),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: theme.colorScheme.surface.withOpacity(0.7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Cotações de 10 Reais (BRL)',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (currencyProvider.isLoading)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            else if (currencyProvider.errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: theme.colorScheme.error,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currencyProvider.errorMessage,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else
                              _buildExchangeRatesList(currencyProvider, theme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: theme.colorScheme.surface.withOpacity(0.7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.currency_exchange_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Conversor de Moedas',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Valor para conversão',
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode
                                    ? theme.colorScheme.surfaceVariant
                                    : Colors.grey[50],
                                prefixIcon: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.attach_money_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              onChanged: (_) => _convertCurrency(),
                            ),
                            const SizedBox(height: 20),
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
                                    theme: theme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildSwapButton(theme),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCurrencyDropdown(
                                    value: _toCurrency,
                                    onChanged: (value) {
                                      setState(() => _toCurrency = value!);
                                      _convertCurrency();
                                    },
                                    label: 'Para',
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.1),
                                    theme.colorScheme.secondary
                                        .withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_amountController.text} ${_fromCurrency} =',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currencyProvider.formatCurrency(
                                        _convertedAmount, _toCurrency),
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Taxa: ${getConversionRate().toStringAsFixed(6)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
