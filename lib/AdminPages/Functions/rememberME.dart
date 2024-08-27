import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberMeService {
  static const String _rememberMeKey = 'rememberMe';

  static Future<bool> getRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<void> setRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<void> signInWithRememberMe(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    if (rememberMe) {
      try {
        // Check if user is already signed in
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // If not signed in, sign in anonymously
          UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
          // Store user credentials
          await setRememberMe(true);
          // Navigate to the home screen upon successful sign-in
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // User is already signed in, navigate to home screen
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Handle sign-in errors
        print('Error signing in with Remember Me: $e');
        // Optionally, clear the "Remember Me" preference if sign-in fails
        await setRememberMe(false);
      }
    }
  }
}
