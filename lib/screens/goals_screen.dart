import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/goal_provider.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';
import 'package:projeto_financeiro/screens/add_goal_screen.dart';
import 'package:projeto_financeiro/screens/goal_detail_screen.dart';
import 'package:projeto_financeiro/screens/dashboard_screen.dart';
import 'package:projeto_financeiro/screens/history_screen.dart';
import 'package:projeto_financeiro/screens/settings_screen.dart';
import 'package:projeto_financeiro/screens/currency_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  Widget _buildDeadlineChip(DateTime? deadline, BuildContext context) {
    if (deadline == null) return const SizedBox();

    final remaining = deadline.difference(DateTime.now());
    final days = remaining.inDays;
    final isExpired = remaining.isNegative;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired
            ? colors.error.withOpacity(0.1)
            : colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? colors.error : colors.primary,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.timer,
            size: 14,
            color: isExpired ? colors.error : colors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            isExpired ? 'Expirado' : '$days dias',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isExpired ? colors.error : colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection(
      String title, List<Goal> goals, BuildContext context) {
    if (goals.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        ...goals.map((goal) => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'goal-image-${goal.id}',
                            child: goal.imagePath != null
                                ? CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        FileImage(File(goal.imagePath!)),
                                  )
                                : CircleAvatar(
                                    radius: 28,
                                    backgroundColor: colors.primaryContainer,
                                    child: Icon(
                                      Icons.flag,
                                      size: 24,
                                      color: colors.primary,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${goal.progressPercentage.toStringAsFixed(1)}% concluído',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value:
                                                goal.progressPercentage / 100,
                                            minHeight: 6,
                                            backgroundColor:
                                                colors.surfaceVariant,
                                            color:
                                                goal.progressPercentage >= 100
                                                    ? colors.tertiary
                                                    : colors.primary,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'R\$${goal.currentAmount.toStringAsFixed(2)}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '/ R\$${goal.targetAmount.toStringAsFixed(2)}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (goal.deadline != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: colors.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').format(goal.deadline!),
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            _buildDeadlineChip(goal.deadline, context),
                          ],
                        ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) {
        final activeGoals = goalProvider.activeGoals;
        final completedGoals = goalProvider.completedGoals;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Minhas Metas'),
            centerTitle: true,
            backgroundColor: colors.primaryContainer,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: _buildDrawer(context, userProvider),
          body: activeGoals.isEmpty && completedGoals.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<GoalProvider>().notifyListeners();
                  },
                  color: colors.primary,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 80),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildGoalSection(
                                'Metas Ativas', activeGoals, context),
                            _buildGoalSection(
                                'Metas Concluídas', completedGoals, context),
                          ]),
                        ),
                      ),
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
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 4,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag,
            size: 72,
            color: colors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma meta criada ainda',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Criar Primeira Meta'),
          ),
        ],
      ),
    );
  }
}
