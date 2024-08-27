import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSignedIn = false;

  FirebaseAuthService() {
    _auth.authStateChanges().listen((User? user) {
      _isSignedIn = user != null;
      notifyListeners();
    });
  }

  bool get isSignedIn => _isSignedIn;

  // Sign up method for admin
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occurred: $e");
      return null;
    }
  }

  // Sign in method for admin
  Future<User?> signInWithEmailAndPassword(String email, String password, {bool rememberMe = false}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (rememberMe) {
        // Save login state to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
      }
      return credential.user;
    } catch (e) {
      print("Some error occurred: $e");
      return null;
    }
  }

  // Sign out method
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
