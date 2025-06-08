import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_financeiro/models/user_model.dart';
import 'package:projeto_financeiro/models/transaction_model.dart';
import 'package:projeto_financeiro/models/goal_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> saveUserData({
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<UserData?> getUserData() async {
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserData(
          name: data['name'] ?? 'Usuário',
          email: data['email'] ?? '',
          photoUrl: data['photoUrl'] ?? '',
          lastLogin:
              (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  Stream<List<TransactionModel>> getTransactions() {
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> saveGoal(GoalModel goal) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id)
        .set(goal.toMap());
  }

  Stream<List<GoalModel>> getGoals() {
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GoalModel.fromMap(doc.data())).toList());
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  Future<void> deleteGoal(String goalId) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .delete();
  }
}
