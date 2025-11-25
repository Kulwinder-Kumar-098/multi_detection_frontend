import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  String? _userEmail;
  bool _rememberMe = false;
  bool _approved = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  bool get rememberMe => _rememberMe;
  bool get approved => _approved;

  AuthProvider() {
    _initFromStorage();
    // listen to auth state changes (optional)
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _isLoggedIn = false;
        _userEmail = null;
        _approved = false;
      }
      notifyListeners();
    });
  }

  Future<void> _initFromStorage() async {
    // auto-login if we stored credentials (optional)
    final storedEmail = await _secure.read(key: 'user_email');
    final storedPassword = await _secure.read(key: 'user_password');
    final remember = await _secure.read(key: 'remember_me');
    _rememberMe = remember == '1';
    if (_rememberMe && storedEmail != null && storedPassword != null) {
      await login(storedEmail, storedPassword, true);
    }
  }

  // ----- NEW: checkLoginStatus used by splash screen -----
  Future<void> checkLoginStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _isLoggedIn = true;
        _userEmail = user.email;
        if (_userEmail != null) {
          _approved = await _checkApproval(_userEmail!);
        }
      } else {
        _isLoggedIn = false;
        _userEmail = null;
        _approved = false;
      }
    } catch (_) {
      _isLoggedIn = false;
      _userEmail = null;
      _approved = false;
    } finally {
      notifyListeners();
    }
  }
  // -------------------------------------------------------

  Future<Map<String, dynamic>> register(String email, String password, String name, {bool rememberMe = false}) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Optionally add user to 'users' collection
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Do NOT auto-approve—admin should add them to allowed_students document.
      _rememberMe = rememberMe;
      if (rememberMe) {
        await _secure.write(key: 'user_email', value: email);
        await _secure.write(key: 'user_password', value: password);
        await _secure.write(key: 'remember_me', value: '1');
      }
      // After register, still enforce approval check
      final check = await _checkApproval(email);
      return {'ok': true, 'approved': check};
    } on FirebaseAuthException catch (e) {
      return {'ok': false, 'error': e.message ?? e.code};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password, bool rememberMe) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoggedIn = true;
      _userEmail = email;
      _rememberMe = rememberMe;

      if (rememberMe) {
        await _secure.write(key: 'user_email', value: email);
        await _secure.write(key: 'user_password', value: password);
        await _secure.write(key: 'remember_me', value: '1');
      } else {
        await _secure.delete(key: 'user_email');
        await _secure.delete(key: 'user_password');
        await _secure.delete(key: 'remember_me');
      }

      _approved = await _checkApproval(email);
      notifyListeners();
      return {'ok': true, 'approved': _approved};
    } on FirebaseAuthException catch (e) {
      return {'ok': false, 'error': e.message ?? e.code};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isLoggedIn = false;
    _userEmail = null;
    _approved = false;
    await _secure.delete(key: 'user_email');
    await _secure.delete(key: 'user_password');
    await _secure.delete(key: 'remember_me');
    notifyListeners();
  }

  Future<bool> _checkApproval(String email) async {
    try {
      final normalized = email.toLowerCase();
      final doc = await _firestore.collection('allowed_students').doc(normalized).get();
      if (!doc.exists) return false;
      final data = doc.data();
      final approved = data?['approved'] == true;
      _approved = approved;
      return approved;
    } catch (e) {
      return false;
    }
  }
}
