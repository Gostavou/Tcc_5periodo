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
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.name,
    this.imagePath,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.isCompleted = false,
    List<GoalContribution>? contributions,
    DateTime? createdAt,
  })  : contributions = contributions ?? [],
        createdAt = createdAt ?? DateTime.now();

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
      createdAt: (map['createdAt'] as Timestamp).toDate(),
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    String? imagePath,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    bool? isCompleted,
    List<GoalContribution>? contributions,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      contributions: contributions ?? this.contributions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;
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
