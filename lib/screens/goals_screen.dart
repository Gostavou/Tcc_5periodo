import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/goal_provider.dart';
import 'package:projeto_financeiro/screens/add_goal_screen.dart';
import 'package:projeto_financeiro/screens/goal_detail_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  Widget _buildDeadlineInfo(DateTime? deadline) {
    if (deadline == null) return const SizedBox();

    final remaining = deadline.difference(DateTime.now());
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final isExpired = remaining.isNegative;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(deadline),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              isExpired ? 'Expirado' : '$days dias e $hours horas',
              style: TextStyle(
                fontSize: 12,
                color: isExpired ? Colors.red : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalSection(
      String title, List<Goal> goals, BuildContext context) {
    if (goals.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...goals.map((goal) => Card(
              margin: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalDetailScreen(goal: goal),
                    ),
                  );
                  Provider.of<GoalProvider>(context, listen: false)
                      .notifyListeners();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          goal.imagePath != null
                              ? CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      FileImage(File(goal.imagePath!)),
                                )
                              : const CircleAvatar(
                                  radius: 25,
                                  child: Icon(Icons.flag, size: 20),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${goal.progressPercentage.toStringAsFixed(1)}% (R\$${goal.currentAmount.toStringAsFixed(2)}/R\$${goal.targetAmount.toStringAsFixed(2)})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal.progressPercentage / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        color: goal.progressPercentage >= 100
                            ? Colors.green
                            : Colors.blue,
                      ),
                      if (goal.deadline != null)
                        _buildDeadlineInfo(goal.deadline),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) {
        final activeGoals = goalProvider.activeGoals;
        final completedGoals = goalProvider.completedGoals;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Minhas Metas'),
          ),
          body: goalProvider.activeGoals.isEmpty &&
                  goalProvider.completedGoals.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<GoalProvider>().notifyListeners();
                  },
                  child: ListView(
                    children: [
                      _buildGoalSection('Metas Ativas', activeGoals, context),
                      _buildGoalSection(
                          'Metas Concluídas', completedGoals, context),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddGoalScreen(),
                ),
              );
              goalProvider.notifyListeners();
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag, size: 50, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Nenhuma meta criada ainda',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddGoalScreen(),
                ),
              );
              if (context.mounted) {
                context.read<GoalProvider>().notifyListeners();
              }
            },
            child: const Text('Criar primeira meta'),
          ),
        ],
      ),
    );
  }
}
