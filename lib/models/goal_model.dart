import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String name;
  final String? imagePath;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isCompleted;
  final List<GoalContribution> contributions;

  GoalModel({
    required this.id,
    required this.name,
    this.imagePath,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.isCompleted,
    required this.contributions,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      targetAmount: map['targetAmount'].toDouble(),
      currentAmount: map['currentAmount'].toDouble(),
      deadline: map['deadline'] != null
          ? (map['deadline'] as Timestamp).toDate()
          : null,
      isCompleted: map['isCompleted'],
      contributions: (map['contributions'] as List<dynamic>?)
              ?.map((e) => GoalContribution.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isCompleted': isCompleted,
      'contributions': contributions.map((e) => e.toMap()).toList(),
    };
  }
}

class GoalContribution {
  final String id;
  final double amount;
  final DateTime date;
  final bool includedInCharts;

  GoalContribution({
    required this.id,
    required this.amount,
    required this.date,
    required this.includedInCharts,
  });

  factory GoalContribution.fromMap(Map<String, dynamic> map) {
    return GoalContribution(
      id: map['id'],
      amount: map['amount'].toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      includedInCharts: map['includedInCharts'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'includedInCharts': includedInCharts,
    };
  }
}
