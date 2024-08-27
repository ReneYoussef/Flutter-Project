import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/widgets.dart';

import '../Utils/authUtil.dart';
import 'Adding/AddVoters.dart';

class Voters extends StatefulWidget {
  const Voters({Key? key}) : super(key: key);

  @override
  State<Voters> createState() => _VotersState();
}

class _VotersState extends State<Voters> {
  //////////////////////////////Function////////////////////////////////

  File? _excelFile;
  List<List<dynamic>> _excelData = [];
  int _currentSortColumn = 0;
  bool _isAscending = true;
  bool _isLoading = false;
  TextEditingController ageController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController VoterVillageController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
  }
  @override
  void initState() {
    super.initState();
    _retrieveFromFirestore();


  }
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete all data?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearTable();
              },
              child: Text('Delete'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
//this function retrives all the data of the voters from collection Voters_data after the upload of the excel file of after the adding of a new voter manualy

  Future<void> _retrieveFromFirestore() async {
    setState(() {
      _isLoading = true;
      _excelData = [];
    });
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection('Voters_data');

      QuerySnapshot querySnapshot = await collection.get();

      setState(() {
        querySnapshot.docs.forEach((doc) {
          List<dynamic> VoterData = [
            doc['Name'],
            doc['Email'],
            doc['Age'],
            doc['Phone Number'],
            doc['Voter Village'],
            doc['role'],

          ];
          _excelData.add(VoterData);
        });
        _isLoading = false;
      });
    } catch (e) {
      print('Error retrieving data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx', 'csv'],
    );

    if (result != null) {
      setState(() {
        _excelFile = File(result.files.single.path!);
        _loadExcelData();
      });
    }
  }

  // this function clear all the collection of the Voters
  void _clearTable() async {
    CollectionReference collection =
    FirebaseFirestore.instance.collection('Voters_data');
    QuerySnapshot querySnapshot = await collection.get();
    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });
    setState(() {
      _excelData.clear();
      _excelFile = null;
    });
  }



  Future<void> _loadExcelData() async {
    final bytes = await _excelFile!.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final table = excel.tables.keys.first;
    setState(() {
      _excelData.clear();
      _excelData.add([
        'Name',
        'Email',
        'Age',
        'Phone Number',
        'Voter Village',
        'role',

      ]);
      _excelData.addAll(
        excel.tables[table]!.rows.map((row) {
          List<dynamic> rowData = [];
          for (var cell in row) {
            rowData.add(cell?.value);
          }
          return rowData;
        }),
      );
    });
  }


  Future<void> resendPasswordReset() async {
    try {
      // Get all documents in the Firestore collection 'candidates'
      QuerySnapshot VoterSnapshot = await FirebaseFirestore.instance.collection('Voters_data').get();
      for (int i = 0; i < VoterSnapshot.docs.length; i++) {

        // Get email from the document
        Map<String, dynamic>? data = VoterSnapshot.docs[i].data() as Map<String, dynamic>?;
        String? email = data?['Email'];

        if (email != null) {
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
            print('Password reset email resent to $email');

          } catch (e) {
            print('Error resending password reset email to $email: $e');
          }
        } else {
          print('Email not found in candidate data');
        }
      }
    } catch (e) {
      print('Error resending password reset emails: $e');
    }
  }




  Future<void> _saveToFirestore() async {
    print('Saving data to Firestore...');

    CollectionReference candidatesCollection = FirebaseFirestore.instance.collection('Voters_data');
    FirebaseAuth auth = FirebaseAuth.instance;

    User? currentAdmin = auth.currentUser;
    DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance.collection('Admins').doc(currentAdmin?.uid).get();
    String adminEmail = adminSnapshot.get('email');
    String adminPassword = adminSnapshot.get('password');


    QuerySnapshot existingCandidates = await candidatesCollection.get();
    Set<String> existingEmails = existingCandidates.docs.map((doc) => doc['Email'] as String).toSet();

    int savedCount = 0;
    int skippedCount = 0;

    for (int i = 1; i < _excelData.length; i++) {
      String email = _excelData[i][1].toString();
      int age = int.parse(_excelData[i][2].toString());

      if (age < 22) {
        print("Age of Voter with email $email is below 22 Can't be Added  Skipping...");
        skippedCount++;
        continue;
      }

      if (!existingEmails.contains(email)) {
        String password = _generatePassword();

        try {
          await auth.signOut();

          UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
          String? uid = userCredential.user?.uid;

          await candidatesCollection.doc(uid).set({
            'Name': _excelData[i][0].toString(),
            'Email': email,
            'Age': age,
            'Phone Number': _excelData[i][4].toString(),
            'Voter Village': capitalize(_excelData[i][3].toString()),
            'role': _excelData[i][5].toString(),
            'hasVoted': false,
            'imagelink':''
          });

          savedCount++;
          // await _sendEmailVerification(userCredential.user!);
          await _sendPasswordResetEmail(email);
          await auth.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
        } catch (e) {
          print('Error creating user for email $email: $e');
          skippedCount++;
        }
      } else {
        print('Email $email already exists. Skipping...');
        skippedCount++;
      }
    }

    print('Saved $savedCount records. Skipped $skippedCount records.');
  }

  String _generatePassword() {
    return '123123';
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } catch (e) {
      print('Error sending password reset email to $email: $e');
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voters"),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.trash),
            onPressed: () => _showConfirmationDialog(context),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              iconColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(

                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 30),
                    ),
                    onPressed: _pickExcelFile,
                    child: Text('Pick Excel File', textAlign: TextAlign.center,),
                  ),

                  SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: () => _saveToFirestore(),
                    child: Text('Save The Data',textAlign: TextAlign.center,),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 30),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  IconButton(
                  icon: Icon(CupertinoIcons.mail),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    iconColor: MaterialStateProperty.all<Color>(Colors.black),

                  ),
                  onPressed: resendPasswordReset
              ),

                IconButton(
                  icon: Icon(CupertinoIcons.person_add),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    iconColor: MaterialStateProperty.all<Color>(Colors.black),

                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AddVoters()),
                    );
                  },
                ),
                ],
              ),

              SizedBox(width: 40,),

              SizedBox(
                height: 10,
                width: 20,
              ),
              Text(
                'File: ${_excelFile != null ? _excelFile!.path.split('/').last : 'No file selected'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: DataTable(
                        border: TableBorder.all(width: 2, borderRadius: BorderRadius.circular(10)),
                        showBottomBorder: true,
                        sortColumnIndex: _currentSortColumn,
                        sortAscending: _isAscending,
                        headingRowColor: MaterialStateProperty.all(Colors.blue),

                        columns: [

                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Age')),
                          DataColumn(label: Text('Phone Number')),
                          DataColumn(
                            label: Text('City'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _currentSortColumn = columnIndex;
                                _isAscending = ascending;
                                if (ascending) {
                                  _excelData.sort((a, b) => a[4].compareTo(b[4])); // Assuming 'City' is at index 4
                                } else {
                                  _excelData.sort((a, b) => b[4].compareTo(a[4])); // Assuming 'City' is at index 4
                                }
                              });
                            },
                          ),
                          DataColumn(label: Text('Role')),
                        ],
                        rows: _excelData.isNotEmpty
                            ? _excelData.skip(1).map<DataRow>((row) {
                          return DataRow(
                            cells: row.map<DataCell>((cell) {
                              return DataCell(Text(cell.toString()));
                            }).toList(),
                          );
                        }).toList()
                            : [],
                      ),
                    ),
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


// static Future<void> _sendEmailVerification(User user) async {
//   await user.sendEmailVerification();
//   print('Verification email sent to ${user.email}');
// }

// String _generatePassword() {
//
//   const String _chars =
//       'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//
//
//   const int _passwordLength = 10;
//
//
//   final Random _rnd = Random.secure();
//
//   return String.fromCharCodes(Iterable.generate(_passwordLength,
//       (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
// }
