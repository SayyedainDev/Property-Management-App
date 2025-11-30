import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

class LoginP extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  Future<bool> signin(
    String username,
    String Email,
    String Password,
    String Location,
    String gender,
    String Contactinf0,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: Email, password: Password);

      await _firebase.collection('users').doc(userCredential.user!.uid).set({
        'user_name': username,
        'email': Email,
        'location': Location,
        'gender': gender,
        'createdAt': DateTime.now(),
        'contact': Contactinf0,
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", userCredential.user!.uid);

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred')));
      return false;
    }
  }

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", userCredential.user!.uid);

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred')));
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    _userData = null;
    notifyListeners();
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// 🔹 Fetch user profile data from Firestore
  Future<void> fetchUserProfile() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot doc = await _firebase
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }
}
