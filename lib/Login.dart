import 'package:ielect/AdminPages/Navbar.dart';
import 'package:ielect/UsersPages/user%20Pages/Navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'Utils/AppStyles.dart';
import 'Utils/authUtil.dart';
import 'AdminPages/AdminRegister.dart';
import 'AdminPages/Functions/Admin_auth_services.dart';
import 'AdminPages/Functions/forgetpasswordpage.dart';

class User_Login extends StatefulWidget {
  const User_Login({Key? key}) : super(key: key);

  @override
  State<User_Login> createState() => _User_LoginState();
}

class _User_LoginState extends State<User_Login> {

  //////////////////////////////////Function////////////////////////////////////

  final FirebaseAuthService _auth = FirebaseAuthService();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool rememberMe = false;

  void _autoSignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('rememberMe');
    if (rememberMe != null && rememberMe) {
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');
      if (email != null && password != null) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _checkRememberMe();
    _autoSignIn();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoSignIn();
  }


  void _checkRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('rememberMe');
    if (rememberMe != null) {
      setState(() {
        this.rememberMe = rememberMe;
      });
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    String password = _passwordController.text;
    String email = _emailController.text;


    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      bool isAdmin = await AuthUtils.checkAdminStatus();
      bool isUser = await AuthUtils.checkUserStatus();

      if (isAdmin) {
        print("User Successfully Signed in as Admin");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminNavbar()),
        );
      }

      else if (isUser) {
        print("User Successfully Signed in as User");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserNavbar()),
        );
      }
      else {
        print("User is not Valid");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You are not allowed to login.")));
        _emailController.clear();
        _passwordController.clear();
      }
    } else {
      print("Some error happened");
    }
  }


////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            color: Colors.white10,
            child: Stack(
              children: [
                Positioned(
                  top:
                  -450, // Adjusted value to bring the child widget into view
                  left:
                  -300, // Adjusted value to bring the child widget into view
                  child: Container(
                    width: 600,
                    height: 800,
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.black, width: 1),
                      color: Colors.blue.shade900.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 30,
                          spreadRadius: 30,
                          offset: Offset(5, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 320,
                          top: 500,
                          child: Text(
                            ' "Voting is not\n only our right \n It is our power."',
                            style: GoogleFonts.habibi(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF505050),
                                    blurRadius: 30,
                                    offset: Offset(4, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 300,
                  left: 100,
                  child: Container(
                    width: 600,
                    height: 800,
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.black, width: 1),
                      color: Colors.blue.shade900.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 30,
                          spreadRadius: 30,
                          offset: Offset(5, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 100, // Adjust the top position as needed
                          right: 150, // Adjust the left position as needed
                          child: Transform.scale(
                            scale:
                            0.85,
                            // Adjust the scale to change the size of the image
                            child: Opacity(
                              opacity: 0.66, // Adjust the opacity as needed
                              child: Image.asset(
                                'assets/image/lebanon map-01.png',
                                width: 500, // Adjust the width of the image
                                height: 500, // Adjust the height of the image
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 140, 20,
                                screenHeight * 0.1), // Adjusted padding
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 20),
                                Positioned(
                                  left: 300,
                                  right: 500,
                                  child: Transform.scale(
                                    scale: 0.85,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          Colors.transparent,
                                          BlendMode.difference),
                                      child: Image.asset(
                                        'assets/image/Senior logo.png',
                                        width: 300,
                                        height: 300,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(Icons.email),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                                color: Colors.black12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white70,
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                              color: Styles.textColor),
                                          hintStyle: TextStyle(
                                              color: Styles.textColor),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty ||
                                              !value.contains('@')) {
                                            return 'Please enter a Valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(Icons.key),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                                color: Colors.black12,
                                                width: 5.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white70,
                                          labelText: 'Password',
                                          labelStyle: TextStyle(
                                              color: Styles.textColor),
                                          hintStyle: TextStyle(
                                              color: Styles.textColor),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (value.length < 10) {
                                            return 'Password must be at least 10 characters long';
                                          }
                                          if (!value
                                              .contains(RegExp(r'[A-Z]'))) {
                                            return 'Password must contain at least one uppercase letter';
                                          }
                                          if (!value.contains(RegExp(
                                              r"[!@#$%^&*()_+{}|:<>?~=]"))) {
                                            return 'Password must contain at least one symbol';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    SizedBox(
                                        height:
                                        3),
                                    // Adjusted space between last field and button
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                          EdgeInsets.fromLTRB(19, 8, 0, 0),
                                          height: 37,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ForgetPasswordPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Forget Password?',
                                              style: TextStyle(

                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black,
                                              width:
                                              .5), // Define the border color
                                          borderRadius: BorderRadius.circular(
                                              25.0), // Optionally, define border radius
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 45,
                                          child: ElevatedButton(
                                            onPressed: _signIn,
                                            child: Text(
                                              'Login',
                                              style: TextStyle(
                                                  color: Styles.HomeTitle),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              Colors.blue.shade500,
                                              elevation: 10,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(25.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Don't have an account?",style: TextStyle(

                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800),),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AdminRegister(),
                                              ),
                                            );
                                          },
                                          child: Text("Sign up",style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800),),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Developed by Rene Youssef ',
                                style: TextStyle(color: Colors.black),
                              ),
                              Icon(
                                Icons.copyright,
                                size: 16,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
