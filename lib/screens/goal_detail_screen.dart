import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/goal_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

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

      // Acesso correto seguindo o padrão do goals_screen
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

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        // Acesso correto seguindo o padrão do goals_screen
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

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  goalProvider.removeGoal(goal.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (goal.imagePath != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(goal.imagePath!),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Seção de Progresso
                    Text(
                      'Progresso:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      minHeight: 25,
                      backgroundColor: Colors.grey[300],
                      color: progressPercentage >= 100
                          ? Colors.green
                          : Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${progressPercentage.toStringAsFixed(1)}% concluído (R\$${goal.currentAmount.toStringAsFixed(2)}/R\$${goal.targetAmount.toStringAsFixed(2)})',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Seção de Prazo
                    if (goal.deadline != null)
                      _buildDeadlineInfo(goal.deadline!),

                    // Seção de Adicionar Contribuição
                    if (!goal.isCompleted) ...[
                      const Text(
                        'Adicionar contribuição:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addContribution(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _includeInCharts,
                            onChanged: (value) {
                              setState(() {
                                _includeInCharts = value!;
                              });
                            },
                          ),
                          const Text('Incluir nos gráficos e histórico'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addContribution,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Adicionar Valor'),
                      ),
                    ],

                    // Histórico de Contribuições
                    _buildContributionHistory(goal),
                  ],
                ),
              ),
              if (_showCongrats)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.celebration,
                                size: 60,
                                color: Colors.amber,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Parabéns!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Você concluiu a meta:',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                goal.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showCongrats = false;
                                  });
                                },
                                child: const Text('Fechar'),
                              ),
                            ],
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

  Widget _buildDeadlineInfo(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final isExpired = remaining.isNegative;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prazo: ${DateFormat('dd/MM/yyyy').format(deadline)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              isExpired ? 'Expirado' : '$days dias e $hours horas',
              style: TextStyle(
                color: isExpired ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionHistory(Goal goal) {
    if (goal.contributions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Histórico de Contribuições',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goal.contributions.length,
          itemBuilder: (context, index) {
            final contrib = goal.contributions[index];
            return Dismissible(
              key: Key(contrib.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
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
                      'Deseja remover R\$${contrib.amount.toStringAsFixed(2)}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) => _removeContribution(contrib.id),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text(
                    'R\$${contrib.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy - HH:mm').format(contrib.date),
                  ),
                  trailing: Icon(
                    contrib.includedInCharts ? Icons.bar_chart : Icons.block,
                    color:
                        contrib.includedInCharts ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
