import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up method for admin
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occurred: $e");
    }
    return null;
  }

  // Sign in method for admin
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print("Some error occurred: $e");
    }
    return null;
  }

  // Sign out method
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
