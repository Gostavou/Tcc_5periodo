import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GoalContribution {
  final String id;
  final double amount;
  final DateTime date;
  final bool includedInCharts;

  GoalContribution({
    required this.amount,
    required this.date,
    required this.includedInCharts,
  }) : id = const Uuid().v4();
}

class Goal {
  final String id;
  String name;
  String? imagePath;
  double targetAmount;
  double currentAmount;
  DateTime? deadline;
  List<GoalContribution> contributions;
  bool isCompleted;

  Goal({
    required this.name,
    this.imagePath,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    List<GoalContribution>? contributions,
    this.isCompleted = false,
  })  : id = const Uuid().v4(),
        contributions = contributions ?? [];

  double get progressPercentage => (currentAmount / targetAmount) * 100;

  void addContribution(double amount, bool includeInCharts) {
    currentAmount += amount;
    contributions.add(GoalContribution(
      amount: amount,
      date: DateTime.now(),
      includedInCharts: includeInCharts,
    ));

    // Verifica se a meta foi concluída
    if (currentAmount >= targetAmount) {
      isCompleted = true;
    }
  }

  void removeContribution(String contributionId) {
    final contribution =
        contributions.firstWhere((c) => c.id == contributionId);
    currentAmount -= contribution.amount;
    contributions.removeWhere((c) => c.id == contributionId);

    // Se estava concluída e agora não está mais
    if (isCompleted && currentAmount < targetAmount) {
      isCompleted = false;
    }
  }
}

class GoalProvider with ChangeNotifier {
  final List<Goal> _goals = [];
  final List<Goal> _completedGoals = [];

  List<Goal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void addContribution(String goalId, double amount, bool includeInCharts) {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    final wasCompletedBefore = goal.isCompleted;

    goal.addContribution(amount, includeInCharts);

    // Se a meta foi concluída agora
    if (goal.isCompleted && !wasCompletedBefore) {
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void removeContribution(String goalId, String contributionId) {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    goal.removeContribution(contributionId);
    notifyListeners();
  }

  void editGoal(String goalId, Goal updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();
    }
  }

  void removeGoal(String goalId) {
    _goals.removeWhere((g) => g.id == goalId);
    notifyListeners();
  }
}
