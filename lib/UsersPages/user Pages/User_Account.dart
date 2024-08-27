import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';


import '../../Login.dart';
import '../../Utils/AppStyles.dart';
import 'Navbar.dart';

import 'package:image/image.dart' as img;

class User_Account extends StatefulWidget {
  const User_Account({super.key});

  @override
  State<User_Account> createState() => _User_AccountState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final ImagePicker _imagePicker = ImagePicker();

class _User_AccountState extends State<User_Account> {
  late TextEditingController _emailController;
  late TextEditingController _userIdController;
  late TextEditingController _usernameController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _userRoleController;
  late TextEditingController _userVillageController;
  late TextEditingController _UserAgeController;
  late TextEditingController _userPhoneController;
  String? imageUrl;
  String? currentUserDisplayName;
  String? currentUserDisplayCity;
  String? currentUserDisplayRole;
  String? currentUserDisplayAge;
  String? currentUserDisplayPhone;
  String? currentUserDisplayimage;
  String? currentUserStatus;

  Uint8List? _image;
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _userIdController = TextEditingController();
    _usernameController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _userRoleController = TextEditingController();
    _userVillageController = TextEditingController();
    _UserAgeController = TextEditingController();
    loadUserData();
    getCurrentUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _userIdController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    _UserAgeController.dispose();
    _userVillageController.dispose();
    _userRoleController.dispose();
    super.dispose();
  }

  void loadUserData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // If user is not null, set the email and password
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
        _userIdController.text = user.uid ?? '';
        _confirmPasswordController.text = '******';
      });
    }
  }

  Future<void> pickImage() async {
    setState(() {
      isloading = true;
    });

    try {
      XFile? res = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (res != null) {
        await UploadImageToFirebase(File(res.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to pick Image: $e'),
      ));
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> UploadImageToFirebase(File image) async {
    setState(() {
      isloading = true;
    });
    try {
      // Read the file
      List<int> imageBytes = await image.readAsBytes();

      // Decode the image
      img.Image? originalImage =
          img.decodeImage(Uint8List.fromList(imageBytes));

      // Check if image is null
      if (originalImage != null) {
        // Resize the image to reduce size
        img.Image resizedImage = img.copyResize(originalImage, width: 800);

        // Encode the image to PNG format
        List<int> resizedBytes = img.encodePng(resizedImage);

        // Convert to Uint8List
        Uint8List resizedUint8List = Uint8List.fromList(resizedBytes);

        // Create a Reference to Firebase Storage
        Reference reference = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().microsecondsSinceEpoch}.png');

        // Upload the resized image
        await reference.putData(resizedUint8List);

        // Get download URL
        String imageUrl = await reference.getDownloadURL();

        // Get current user
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Check user role
          String role = await getUserRole(user.uid);

          // Store image URL based on user role
          if (role == 'candidate') {
            await FirebaseFirestore.instance
                .collection('candidates')
                .doc(user.uid)
                .set({'imagelink': imageUrl}, SetOptions(merge: true));
          } else if (role == 'voter') {
            await FirebaseFirestore.instance
                .collection('Voters_data')
                .doc(user.uid)
                .set({'imagelink': imageUrl}, SetOptions(merge: true));
          }
        }
        await loadUserData;
        await getCurrentUserData;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            content: Text('Upload Complete'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed To Upload Image: Image is null'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed To Upload Image: $e'),
        ),
      );
    }
    setState(() {
      isloading = false;
    });
  }

  Future<String> getUserRole(String uid) async {
    try {
      // Check candidates collection
      DocumentSnapshot candidateSnapshot = await FirebaseFirestore.instance
          .collection('candidates')
          .doc(uid)
          .get();

      if (candidateSnapshot.exists) {
        return candidateSnapshot['role'];
      }

      // Check voters_data collection
      DocumentSnapshot voterSnapshot = await FirebaseFirestore.instance
          .collection('Voters_data')
          .doc(uid)
          .get();

      if (voterSnapshot.exists) {
        return voterSnapshot['role'];
      }

      // Default to empty string if user not found in either collection
      return '';
    } catch (e) {
      // Handle error
      print('Error getting user role: $e');
      return '';
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
              MaterialPageRoute(builder: (context) => UserNavbar()),
            );
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Profile',
          style: Styles.headlinestyle2,
        ),
        centerTitle: true,
      ),
      body: Container(
        height: 800,
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.9,
            image: AssetImage(
              'assets/image/electiondashboard.jpg',
            ),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85),
                BlendMode.dstATop),
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    currentUserDisplayimage != null &&
                            currentUserDisplayimage!.isNotEmpty
                        ? SizedBox(
                            width: 110,
                            height: 110,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.34),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(

                                child: Image.network(

                                  currentUserDisplayimage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {

                                    return Image.asset(
                                      'assets/image/file.png',
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    );
                                  },
                                ),
                              ),

                            ),
                          )
                        : SizedBox(

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
                              child: CircleAvatar(

                                child: Image.asset(
                                  'assets/image/file.png',
                                ),
                              ),
                            ),
                          ),
                    if (isloading)
                      Positioned(
                        top: 45,
                        left: 45,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
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
                            color: Colors.transparent,
                          ),
                          child: Icon(Icons.camera,
                              color: Colors.black.withOpacity(0.6)),
                        ),
                        onTap: pickImage,
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
                        style: TextStyle(
                            fontSize: 19, color: Colors.black.withOpacity(0.6)),
                        controller: TextEditingController(
                          text: currentUserDisplayName,
                        ),
                        enabled: false,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.person,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          labelText: 'User Name',
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
                        style: TextStyle(
                            fontSize: 19, color: Colors.black.withOpacity(0.6)),
                        controller: _emailController,
                        enabled: false,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.email,
                            color: Colors.black.withOpacity(0.7),
                          ),
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
                        style: TextStyle(
                            fontSize: 18, color: Colors.black.withOpacity(0.6)),
                        controller: _userIdController,
                        enabled: false,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            FontAwesomeIcons.idCard,
                            color: Colors.black.withOpacity(0.7),
                          ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 19, color: Colors.black.withOpacity(0.6)),
                        controller:
                            TextEditingController(text: currentUserDisplayRole),
                        enabled: false,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            CupertinoIcons.person_crop_circle_badge_checkmark,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          labelText: 'Role',
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
                        style: TextStyle(
                            fontSize: 19, color: Colors.black.withOpacity(0.6)),
                        controller:
                            TextEditingController(text: currentUserDisplayAge),
                        enabled: false,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            FontAwesomeIcons.calendar,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          labelText: 'Age',
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
                        style: TextStyle(
                            fontSize: 19, color: Colors.black.withOpacity(0.6)),
                        controller:
                            TextEditingController(text: currentUserDisplayCity),
                        enabled: false,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            FontAwesomeIcons.city,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          labelText: 'City',
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
                        style: TextStyle(
                            fontSize: 19, color: Colors.black.withOpacity(0.6)),
                        controller: TextEditingController(
                            text: currentUserDisplayPhone),
                        enabled: false,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            FontAwesomeIcons.phone,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Styles.textColor),
                          hintStyle: TextStyle(color: Styles.textColor),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await _auth.signOut();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => User_Login()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text(
                              'Sign Out',
                              style: TextStyle(color: Colors.white),
                            )),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    )

                    // Other form fields and buttons
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('Voters_data')
          .doc(user.uid)
          .snapshots()
          .listen((votersSnapshot) {
        if (votersSnapshot.exists) {
          setState(() {
            currentUserDisplayName = votersSnapshot['Name'];
            currentUserDisplayCity = votersSnapshot['Voter Village'];
            currentUserDisplayRole = votersSnapshot['role'];
            currentUserDisplayAge = votersSnapshot['Age'].toString();
            currentUserDisplayPhone = votersSnapshot['Phone Number'];
            currentUserDisplayimage = votersSnapshot['imagelink'];
          });
        }
      });

      FirebaseFirestore.instance
          .collection('candidates')
          .doc(user.uid)
          .snapshots()
          .listen((candidatesSnapshot) {
        if (candidatesSnapshot.exists) {
          setState(() {
            currentUserDisplayName = candidatesSnapshot['Name'];
            currentUserDisplayCity = candidatesSnapshot['Candidate Village'];
            currentUserDisplayRole = candidatesSnapshot['role'];
            currentUserDisplayAge = candidatesSnapshot['Age'].toString();
            currentUserDisplayPhone = candidatesSnapshot['Phone Number'];
            currentUserDisplayimage = candidatesSnapshot['imagelink'];
          });
        }
      });
    }
  }
}
