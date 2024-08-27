
import 'package:ielect/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils/AppStyles.dart';
import '../Utils/authUtil.dart';
import 'Navbar.dart';


class admin_Account extends StatefulWidget {
  const admin_Account({super.key});

  @override
  State<admin_Account> createState() => _admin_AccountState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;

class _admin_AccountState extends State<admin_Account> {
  late TextEditingController _emailController;
  late TextEditingController _userIdController;
  late TextEditingController _confirmPasswordController;
  String? userId;
  String? _currentAdminEmail;

  Future<String?> getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _userIdController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    getUserId().then((id) {
      setState(() {
        userId = id;
      });
    });
loadUserData();
  }




  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    loadUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _userIdController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void loadUserData() async {

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(user.uid)
          .get();


      if (adminSnapshot.exists) {
        setState(() {
          _currentAdminEmail = adminSnapshot.get('email');
          _userIdController.text = user.uid;
          _emailController.text = _currentAdminEmail ?? '';
        });
      }
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminNavbar()),
            );
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Edit Profile',
          style: Styles.headlinestyle2,
        ),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'assets/image/Senior logo.png',
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 25),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Styles.textColor),
                        hintStyle: TextStyle(color: Styles.textColor),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _userIdController,
                      enabled: false,
                      decoration: InputDecoration(
                        suffixIcon: Icon(CupertinoIcons.creditcard),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                        labelText: 'UserID',
                        labelStyle: TextStyle(color: Styles.textColor),
                        hintStyle: TextStyle(color: Styles.textColor),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: ()async  {
                        await _auth.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => User_Login()),
                        );
                      },
                      child: Text('Sign Out'))

                  // Other form fields and buttons
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
