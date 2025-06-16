import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/models/goal_model.dart';
import 'package:projeto_financeiro/providers/goal_provider.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class GoalDetailScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _includeInCharts = true;
  bool _showCongrats = false;

  void _addContribution() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      final allGoals = [
        ...goalProvider.activeGoals,
        ...goalProvider.completedGoals
      ];
      final goalBefore = allGoals.firstWhere(
        (g) => g.id == widget.goal.id,
        orElse: () => widget.goal,
      );
      final wasCompletedBefore = goalBefore.isCompleted;

      goalProvider.addContribution(
        widget.goal.id,
        amount,
        _includeInCharts,
      );

      final goalAfter = allGoals.firstWhere(
        (g) => g.id == widget.goal.id,
        orElse: () => widget.goal,
      );

      if (!wasCompletedBefore && goalAfter.isCompleted) {
        setState(() {
          _showCongrats = true;
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showCongrats = false;
            });
          }
        });
      }

      _amountController.clear();
    }
  }

  void _removeContribution(String contributionId) {
    Provider.of<GoalProvider>(context, listen: false).removeContribution(
      widget.goal.id,
      contributionId,
    );
  }

  Widget _buildDeadlineCard(DateTime deadline, ThemeData theme) {
    final remaining = deadline.difference(DateTime.now());
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final isExpired = remaining.isNegative;
    final colors = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isExpired ? colors.errorContainer : colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpired ? Icons.timer_off : Icons.timer,
                color: isExpired
                    ? colors.onErrorContainer
                    : colors.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prazo da Meta',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(deadline),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isExpired
                            ? 'Expirado'
                            : 'Faltam $days dias e $hours horas',
                        style: TextStyle(
                          color: isExpired ? colors.error : colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionHistory(GoalModel goal, ThemeData theme) {
    if (goal.contributions.isEmpty) return const SizedBox();

    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico de Contribuições',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...goal.contributions.map((contrib) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: colors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      child: Dismissible(
                        key: Key(contrib.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remover Contribuição?'),
                              content: Text(
                                'Deseja remover a contribuição de R\$${contrib.amount.toStringAsFixed(2)}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'Remover',
                                    style: TextStyle(color: colors.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) =>
                            _removeContribution(contrib.id),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: contrib.includedInCharts
                                  ? colors.primaryContainer
                                  : colors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.attach_money,
                              color: contrib.includedInCharts
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                          title: Text(
                            'R\$${contrib.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy - HH:mm')
                                .format(contrib.date),
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Icon(
                            contrib.includedInCharts
                                ? Icons.bar_chart
                                : Icons.visibility_off,
                            color: contrib.includedInCharts
                                ? colors.primary
                                : colors.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userProvider = Provider.of<UserProvider>(context);

    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final allGoals = [
          ...goalProvider.activeGoals,
          ...goalProvider.completedGoals
        ];
        final goal = allGoals.firstWhere(
          (g) => g.id == widget.goal.id,
          orElse: () => widget.goal,
        );

        final progressPercentage =
            (goal.currentAmount / goal.targetAmount * 100).clamp(0.0, 100.0);
        final isCompleted = progressPercentage >= 100;
        final remainingAmount = goal.targetAmount - goal.currentAmount;

        return Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primaryContainer,
                            colors.primaryContainer.withOpacity(0.7)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (goal.imagePath != null)
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.3,
                                child: Image.file(
                                  File(goal.imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isCompleted
                                      ? 'Meta concluída!'
                                      : '${remainingAmount > 0 ? 'Faltam R\$${remainingAmount.toStringAsFixed(2)}' : 'Você alcançou a meta!'}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colors.onPrimaryContainer
                                        .withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 10,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: colors.onPrimaryContainer,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: colors.error,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Excluir Meta'),
                                    content: const Text(
                                        'Tem certeza que deseja excluir esta meta permanentemente?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          goalProvider.removeGoal(goal.id);
                                          Navigator.pop(ctx);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Excluir',
                                          style: TextStyle(color: colors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Progresso',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? colors.tertiaryContainer
                                              : colors.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isCompleted
                                              ? 'Concluído'
                                              : 'Em andamento',
                                          style: TextStyle(
                                            color: isCompleted
                                                ? colors.onTertiaryContainer
                                                : colors.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Stack(
                                    children: [
                                      LinearProgressIndicator(
                                        value: progressPercentage / 100,
                                        minHeight: 24,
                                        backgroundColor: colors.surfaceVariant,
                                        color: isCompleted
                                            ? colors.tertiary
                                            : colors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            '${progressPercentage.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              color: isCompleted
                                                  ? colors.onTertiary
                                                  : colors.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Arrecadado',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          Text(
                                            'R\$${goal.currentAmount.toStringAsFixed(2)}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Objetivo',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          Text(
                                            'R\$${goal.targetAmount.toStringAsFixed(2)}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (goal.deadline != null)
                            _buildDeadlineCard(goal.deadline!, theme),
                          if (!isCompleted) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Adicionar Contribuição',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Material(
                              borderRadius: BorderRadius.circular(12),
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Valor da contribuição',
                                  prefixText: 'R\$ ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor:
                                      colors.surfaceVariant.withOpacity(0.3),
                                ),
                                style: theme.textTheme.titleMedium,
                                onSubmitted: (_) => _addContribution(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                  'Incluir nos gráficos e histórico'),
                              value: _includeInCharts,
                              onChanged: (value) {
                                setState(() {
                                  _includeInCharts = value;
                                });
                              },
                              activeColor: colors.primary,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addContribution,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                elevation: 3,
                              ),
                              child: const Text('Adicionar Contribuição'),
                            ),
                            const SizedBox(height: 20),
                          ],
                          _buildContributionHistory(goal, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_showCongrats)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.85),
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: _showCongrats ? 1 : 0.9,
                        child: Material(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          elevation: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.celebration,
                                  size: 72,
                                  color: colors.tertiary,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Parabéns!',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.tertiary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Você alcançou sua meta:',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  goal.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showCongrats = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.tertiary,
                                    foregroundColor: colors.onTertiary,
                                    minimumSize: const Size(150, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
