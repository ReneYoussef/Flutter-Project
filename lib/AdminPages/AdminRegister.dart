
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Utils/AppStyles.dart';
import '../Login.dart';
import 'Functions/Admin_auth_services.dart';

class AdminRegister extends StatefulWidget {
  const AdminRegister({Key? key}) : super(key: key);

  @override
  State<AdminRegister> createState() => _AdminRegisterState();
}

class _AdminRegisterState extends State<AdminRegister> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _usernamecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _phonenumbercontroller = TextEditingController();
  File? _image;
  @override
  void dispose() {
    _usernamecontroller.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }
  //////////////////////////////////Function////////////////////////////////////
  void pickImage() async {
    ImagePicker picker = ImagePicker();
    var imageFile = await picker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
      });
    }
  }

  void signup() async {
    String password = _passwordcontroller.text;
    String email = _emailcontroller.text;

    // Create the user in Firebase Authentication
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("User Successfully Created");

      // Send email verification
      await user.sendEmailVerification();

      // Save user data to Firestore
      try {
        await FirebaseFirestore.instance.collection('Admins').doc(user.uid).set({
          'username': _usernamecontroller.text,
          'email': email,
          'phone_number': _phonenumbercontroller.text,
          'role' : 'admin',
          'password':_passwordcontroller.text,
          // Add any other fields you want to save
        });

        // Navigate to the next screen after successful signup
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => User_Login())
        );
      } catch (e) {
        print("Error saving user data: $e");
      }
    } else {
      print("Some error happened");
    }
  }


////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(

            children: [

              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
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
                                child: _image != null
                                    ? Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(
                                  'assets/image/Senior logo.png',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.blue,
                                ),
                                child: Icon(Icons.camera_alt),
                              ),
                              onTap: () {
                                pickImage(); // Call the function to pick an image
                              },
                            ),
                          ),
                        ],
                      ),

                SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _usernamecontroller,
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Styles.textColor),
                            hintStyle: TextStyle(color: Styles.textColor),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _emailcontroller,
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Styles.textColor),
                            hintStyle: TextStyle(color: Styles.textColor),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _passwordcontroller,
                          obscureText: true,
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.key),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.black12,
                                width: 5.0,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Styles.textColor),
                            hintStyle: TextStyle(color: Styles.textColor),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 10) {
                              return 'Password must be at least 10 characters long';
                            }
                            if (!value.contains(RegExp(r'[A-Z]'))) {
                              return 'Password must contain at least one uppercase letter';
                            }
                            if (!value.contains(RegExp(r"[!@#$%^&*()_+{}|:<>?~=]"))) {
                              return 'Password must contain at least one symbol';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _phonenumbercontroller,
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                            labelText: 'Phone number',
                            labelStyle: TextStyle(color: Styles.textColor),
                            hintStyle: TextStyle(color: Styles.textColor),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {

                              signup();
                            },
                            // Changed here
                            child: Text(
                              'Sign up',
                              style: TextStyle(color: Styles.HomeTitle),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) => User_Login()));
                            },
                            child: Text("Login"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

