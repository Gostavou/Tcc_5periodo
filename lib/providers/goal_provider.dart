import 'package:flutter/foundation.dart';
import 'package:projeto_financeiro/models/goal_model.dart';
import 'package:projeto_financeiro/services/database_service.dart';

class GoalProvider with ChangeNotifier {
  late DatabaseService _databaseService;

  GoalProvider({required DatabaseService databaseService}) {
    _databaseService = databaseService;
  }

  void updateDatabaseService(DatabaseService databaseService) {
    _databaseService = databaseService;
    loadGoals();
  }

  List<GoalModel> _goals = [];

  List<GoalModel> get goals => _goals;
  List<GoalModel> get activeGoals =>
      _goals.where((g) => !g.isCompleted).toList();
  List<GoalModel> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  Future<void> loadGoals() async {
    try {
      _databaseService.getGoals().listen((goals) {
        _goals = goals;
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar metas: $e');
      }
    }
  }

  Future<void> addGoal(GoalModel goal) async {
    try {
      await _databaseService.saveGoal(goal);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar meta: $e');
      }
      rethrow;
    }
  }

  Future<void> addContribution(
      String goalId, double amount, bool includeInCharts) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final newContribution = GoalContribution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        date: DateTime.now(),
        includedInCharts: includeInCharts,
      );

      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
        contributions: [...goal.contributions, newContribution],
        isCompleted: (goal.currentAmount + amount) >= goal.targetAmount,
      );

      await _databaseService.updateGoal(updatedGoal);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar contribuição: $e');
      }
      rethrow;
    }
  }

  Future<void> removeContribution(String goalId, String contributionId) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final contribution =
          goal.contributions.firstWhere((c) => c.id == contributionId);

      final updatedContributions =
          goal.contributions.where((c) => c.id != contributionId).toList();
      final newAmount = goal.currentAmount - contribution.amount;

      final updatedGoal = goal.copyWith(
        currentAmount: newAmount,
        contributions: updatedContributions,
        isCompleted: newAmount >= goal.targetAmount,
      );

      await _databaseService.updateGoal(updatedGoal);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover contribuição: $e');
      }
      rethrow;
    }
  }

  Future<void> editGoal(GoalModel updatedGoal) async {
    try {
      await _databaseService.updateGoal(updatedGoal);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao editar meta: $e');
      }
      rethrow;
    }
  }

  Future<void> removeGoal(String goalId) async {
    try {
      await _databaseService.deleteGoal(goalId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover meta: $e');
      }
      rethrow;
    }
  }

  Future<void> clearData() async {
    _goals = [];
    notifyListeners();
  }
}
