import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String name;
  final String email;
  final String photoUrl;
  final DateTime lastLogin;
  final double initialBalance;

  UserData({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.lastLogin,
    required this.initialBalance,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] ?? 'Usuário',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      initialBalance: (map['initialBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
