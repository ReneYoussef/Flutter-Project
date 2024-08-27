import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Utils/authUtil.dart';
import '../Navbar.dart';

class AddCandidate extends StatefulWidget {
  const AddCandidate({Key? key}) : super(key: key);

  @override
  State<AddCandidate> createState() => _AddCandidateState();
}

class _AddCandidateState extends State<AddCandidate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<String>> _cityNamesFuture;
  late String _selectedCity = '';

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _roleController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _villageController = TextEditingController();
  TextEditingController _listController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _roleController.dispose();
    _ageController.dispose();
    _villageController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cityNamesFuture = _fetchCityNames();

    // Initialize _selectedCity with the first city name if available
    _cityNamesFuture.then((cityNames) {
      if (cityNames.isNotEmpty) {
        _selectedCity = cityNames[0];
      }
    });
  }

  Future<List<String>> _fetchCityNames() async {
    try {
      CollectionReference citiesRef = FirebaseFirestore.instance.collection('Cities');
      QuerySnapshot querySnapshot = await citiesRef.get();

      List<String> cityNames = [];
      querySnapshot.docs.forEach((doc) {
        var cityName = doc['name'] as String?;
        if (cityName != null) {
          cityNames.add(cityName);
        }
      });

      // Remove duplicates and convert to list
      cityNames = cityNames.toSet().toList();

      return cityNames;
    } catch (e) {
      print('Error fetching city names: $e');
      return []; // Return an empty list in case of an error
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Candidates'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminNavbar()),
            );
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView( // Wrap your Column with SingleChildScrollView
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                TextFormField(
                  enabled: false,
                  controller: TextEditingController(text: 'candidate'),
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                ),
                TextFormField(
                  controller: _listController,
                  decoration: InputDecoration(labelText: 'list'),
                ),
                SizedBox(height: 20,),
                FutureBuilder<List<String>>(
                  future: _cityNamesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LinearProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<String> cityNames = snapshot.data!;
                      print('City Names: $cityNames');
                      print('Selected City: $_selectedCity');
                      return DropdownButtonFormField<String>(
                        value: _selectedCity,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCity = newValue!;
                          });
                        },
                        items: cityNames.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Select City',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40)
                          ),
                          fillColor: Colors.white, // Change the fill color
                          filled: true, // Enable fill color
                          contentPadding: EdgeInsets.all(12), // Add padding to the dropdown items
                          labelStyle: TextStyle(
                            color: Colors.black, // Change the color of the label
                            fontSize: 18, // Change the font size of the label
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _addCandidates(context),
                  child: Text('Add Candidate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _addCandidates(BuildContext context) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('User is not logged in. Unable to add Candidates.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are not logged in')));
        return;
      }

      final String adminEmail = currentUser.email!;
      DocumentSnapshot adminSnapshot = await _firestore.collection('Admins').doc(currentUser.uid).get();
      if (!adminSnapshot.exists) {
        print('Admin credentials not found.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Admin credentials not found')));
        return;
      }
      final String? adminPassword = (adminSnapshot.data() as Map<String, dynamic>?)?['password'];

      bool isAdmin = await AuthUtils.checkAdminStatus();
      if (!isAdmin) {
        print('Current user is not authorized to add Candidates.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are not authorized to add Candidates')));
        return;
      }

      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String phoneNumber = _phoneNumberController.text;
      String age = _ageController.text;
      String village = _selectedCity; // Use the selected city as the village
      String list = _listController.text;

      int parsedAge = int.tryParse(age) ?? 0;
      if (parsedAge < 25) {
        print('Candidate age is below 25. Cannot add candidate.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Candidate age must be 25 or older')));
        return _clearTextControllers();
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? newUser = userCredential.user;

      if (newUser != null) {
        await _firestore.collection('candidates').doc(newUser.uid).set({
          'Name': name,
          'Email': email,
          'Phone Number': phoneNumber,
          'role': 'candidate',
          'Age': age,
          'Candidate Village': village, // Save the village name
          'list': list,
          'imagelink':''
        });

        print('Candidate added successfully!');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Candidate added successfully')));

        await _auth.signOut();

        if (adminPassword != null) {
          await _auth.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
        } else {
          print('Admin password is null. Unable to sign in.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Admin password is null. Unable to sign in.')));
          return;
        }

        _clearTextControllers();
      } else {
        print('Failed to create a new user.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create a new user')));
      }
    } catch (e) {
      print('Error adding candidate to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add Candidate: $e')));
    }
  }






  void _clearTextControllers() {

    _nameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _roleController.clear();
    _ageController.clear();
    _villageController.clear();
    _passwordController.clear();
    _listController.clear();
  }



}
