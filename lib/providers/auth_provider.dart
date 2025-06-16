import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (password.length < 6) {
        return 'A senha deve ter pelo menos 6 caracteres.';
      }

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'name': '',
        'photoUrl': '',
        'currency': '',
        'initialBalance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Este email já está em uso.';
      } else if (e.code == 'invalid-email') {
        return 'Email inválido.';
      } else if (e.code == 'weak-password') {
        return 'Senha fraca.';
      }
      return e.message;
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        return 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        return 'Email inválido.';
      }
      return e.message;
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return 'Login cancelado';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final user = userCredential.user!;
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL ?? '',
          'currency': '',
          'initialBalance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao logar com Google: $e';
    }
  }

  Future<String?> updateProfile({
    required String uid,
    required String name,
    String? photoUrl,
    required String currency,
    required double initialBalance,
  }) async {
    try {
      if (name.isEmpty) {
        return 'O nome não pode ser vazio.';
      }
      if (currency.isEmpty) {
        return 'Selecione um tipo de moeda.';
      }

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'photoUrl': photoUrl ?? '',
        'currency': currency,
        'initialBalance': initialBalance,
      });

      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao atualizar perfil: $e';
    }
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;

        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
        }

        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar perfil: $e');
      }
      return null;
    }
  }
}
