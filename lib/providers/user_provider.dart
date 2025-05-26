import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = 'Usuário';
  String _email = '';
  String _photoUrl = '';

  String get name => _name;
  String get email => _email;
  String get photoUrl => _photoUrl;

  void updateProfile(String name, String email, String photoUrl) {
    _name = name;
    _email = email;
    _photoUrl = photoUrl;
    notifyListeners();
  }
}
