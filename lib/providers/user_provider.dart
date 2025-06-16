import 'package:flutter/material.dart';
import 'package:projeto_financeiro/services/database_service.dart';
import 'package:projeto_financeiro/models/user_model.dart';

class UserProvider with ChangeNotifier {
  DatabaseService _databaseService;
  UserData? _userData;
  String _localPhotoPath = '';

  UserProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  String get name => _userData?.name ?? 'Usuário';
  String get email => _userData?.email ?? '';
  String get photoUrl => _userData?.photoUrl ?? '';
  double get initialBalance => _userData?.initialBalance ?? 0.0;
  String get localPhotoPath => _localPhotoPath;

  void updateDatabaseService(DatabaseService databaseService) {
    _databaseService = databaseService;
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      _userData = await _databaseService.getUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
      _userData = UserData(
        name: 'Usuário',
        email: '',
        photoUrl: '',
        lastLogin: DateTime.now(),
        initialBalance: 0.0,
      );
      notifyListeners();
    }
  }

  Future<void> ensureUserDataLoaded() async {
    if (_userData == null) {
      await loadUserData();
    }
  }

  Future<void> updateProfile(
    String name,
    String email,
    String photoUrl, {
    String localPhotoPath = '',
  }) async {
    try {
      double currentBalance = _userData?.initialBalance ?? 0.0;

      _userData = UserData(
        name: name,
        email: email,
        photoUrl: photoUrl,
        lastLogin: DateTime.now(),
        initialBalance: currentBalance,
      );

      if (localPhotoPath.isNotEmpty) {
        _localPhotoPath = localPhotoPath;
      }

      await _databaseService.saveUserData(
        name: name,
        email: email,
        photoUrl: photoUrl,
        initialBalance: currentBalance,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  void setLocalPhotoPath(String path) {
    _localPhotoPath = path;
    notifyListeners();
  }

  void clearUser() {
    _userData = null;
    _localPhotoPath = '';
    notifyListeners();
  }
}
