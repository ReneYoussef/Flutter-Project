import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Adding/AddCandidates.dart';

class Candidates extends StatefulWidget {
  const Candidates({Key? key}) : super(key: key);

  @override
  State<Candidates> createState() => _CandidatesState();
}

class _CandidatesState extends State<Candidates> {
  File? _excelFile;
  List<List<dynamic>> _excelData = [];
  int _currentSortColumn = 0;
  bool _isAscending = true;
  bool _isLoading = false;

  TextEditingController ageController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController candidateVillageController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController listController = TextEditingController();
  String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
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


  @override
  void initState() {
    super.initState();
    _retrieveFromFirestore();
  }

  Future<void> _retrieveFromFirestore() async {
    setState(() {
      _isLoading = true;
      _excelData = [];
    });

    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection('candidates');

      QuerySnapshot querySnapshot = await collection.get();

      setState(() {
        querySnapshot.docs.forEach((doc) {
          List<dynamic> candidateData = [
            doc['Name'],
            doc['Email'],
            doc['Age'],
            doc['Phone Number'],
            doc['Candidate Village'],
            doc['list'],
            doc['role'],
          ];
          _excelData.add(candidateData);
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
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      setState(() {
        _excelFile = File(result.files.single.path!);
        _loadExcelData();
      });
    }
  }

  void _clearTable() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('candidates');
    FirebaseAuth auth = FirebaseAuth.instance;

    QuerySnapshot querySnapshot = await collection.get();

    querySnapshot.docs.forEach((doc) async {
      await doc.reference.delete();

      String email = doc['Email'] as String;

      User? user = (await auth.fetchSignInMethodsForEmail(email)).isEmpty
          ? null
          : auth.currentUser;

      if (user != null) {
        try {
          await user.delete();
          print('User with email $email deleted from Authentication.');
        } catch (e) {
          print(
              'Error deleting user with email $email from Authentication: $e');
        }
      }
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
      _excelData
          .add(['Name', 'Email', 'Age', 'Candidate Village', 'Phone Number']);
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

  Future<void> _saveToFirestore() async {
    print('Saving data to Firestore...');

    CollectionReference candidatesCollection = FirebaseFirestore.instance.collection('candidates');
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentAdmin = auth.currentUser;
    DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('Admins')
        .doc(currentAdmin?.uid)
        .get();
    String adminEmail = adminSnapshot.get('email');
    String adminPassword = adminSnapshot.get('password');

    QuerySnapshot existingCandidates = await candidatesCollection.get();

    Set<String> existingEmails = existingCandidates.docs.map((doc) => doc['Email'] as String).toSet();

    int savedCount = 0;
    int skippedCount = 0;

    for (int i = 1; i < _excelData.length; i++) {
      String email = _excelData[i][1].toString();
      int age = int.parse(_excelData[i][2].toString());

      if (age < 25) {
        print('Age of candidate with email $email is below 25. Skipping...');
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
            'Candidate Village': capitalize(_excelData[i][3].toString()),
            'role': _excelData[i][6].toString(),
            'list': _excelData[i][5].toString(),
            'hasVoted': false,
            'imagelink': ''
          });

          savedCount++;

          await auth.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
          await _sendPasswordResetEmail(email);
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


  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } catch (e) {
      print('Error sending password reset email to $email: $e');
    }
  }

  String _generatePassword() {
    return '123123';
  }

  Future<void> resendPasswordReset() async {

    try {
      QuerySnapshot candidatesSnapshot =
          await FirebaseFirestore.instance.collection('candidates').get();

      int delayInSeconds = 40;
      for (int i = 0; i < candidatesSnapshot.docs.length; i++) {
        Map<String, dynamic>? data =
            candidatesSnapshot.docs[i].data() as Map<String, dynamic>?;
        String? email = data?['Email'];

        if (email != null) {
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
            print('Password reset email resent to $email');

            await Future.delayed(Duration(seconds: delayInSeconds));
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
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Candidates"),
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
                    onPressed: _pickExcelFile,
                    child: Text(
                      'Pick Excel File',
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 30),
                      maximumSize: Size(140, 40),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: _saveToFirestore,
                    child: Text(
                      'Save The Data',
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 30),
                      maximumSize: Size(140, 40),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                      icon: Icon(CupertinoIcons.mail),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        iconColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: resendPasswordReset),
                  IconButton(
                    icon: Icon(CupertinoIcons.person_add),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      iconColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AddCandidate()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
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
                              border: TableBorder.all(
                                  width: 2,
                                  borderRadius: BorderRadius.circular(10)),
                              showBottomBorder: true,
                              sortColumnIndex: _currentSortColumn,
                              sortAscending: _isAscending,
                              headingRowColor:
                                  MaterialStateProperty.all(Colors.blue),
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
                                        _excelData.sort((a, b) => a[4].compareTo(
                                            b[4])); // Assuming 'City' is at index 4
                                      } else {
                                        _excelData.sort((a, b) => b[4].compareTo(
                                            a[4])); // Assuming 'City' is at index 4
                                      }
                                    });
                                  },
                                ),
                                DataColumn(label: Text('List')),
                                DataColumn(label: Text('Role')),
                              ],
                              rows: _excelData.isNotEmpty
                                  ? _excelData.skip(1).map<DataRow>((row) {
                                      return DataRow(
                                        cells: row.map<DataCell>((cell) {
                                          return DataCell(
                                              Text(cell.toString()));
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