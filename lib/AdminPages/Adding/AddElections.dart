import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../Utils/AppStyles.dart';
import '../Navbar.dart';

class AddElection extends StatefulWidget {
  const AddElection({Key? key}) : super(key: key);

  @override
  State<AddElection> createState() => _AddElectionState();
}

class _AddElectionState extends State<AddElection> {
  File? _image;
  String url ='';

  List<String> governorates = [
    'Akkar',
    'Baalbek-Hermel',
    'Beirut',
    'Beqaa',
    'Mount Lebanon',
    'Nabatieh',
    'North',
    'South',
  ];

  late String selectedGov;

  @override
  void initState() {
    super.initState();
    selectedGov = governorates.first; // Initialize here
  }

  TextEditingController name = TextEditingController();
  TextEditingController population = TextEditingController();
  TextEditingController governorate = TextEditingController();
  TextEditingController CouncilmembersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Election'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            iconColor: MaterialStateProperty.all<Color>(Colors.black),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminNavbar()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white30,
            margin: EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Styles.primaryColor),
                      ),
                      filled: true,
                      fillColor: Styles.bgcolor,
                      labelText: ' Election Name',

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
                    controller: population,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Styles.primaryColor),
                      ),
                      filled: true,
                      fillColor: Styles.bgcolor,
                      labelText: 'City Population',

                      labelStyle: TextStyle(color: Styles.textColor),
                      hintStyle: TextStyle(color: Styles.textColor),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: selectedGov,
                onChanged: (newValue) {
                  setState(() {
                    selectedGov = newValue!;
                  });
                },
                items: governorates.map((governorate) {
                  return DropdownMenuItem<String>(
                    value: governorate,
                    child: Text(governorate),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Styles.primaryColor),
                  ),
                  filled: true,
                  fillColor: Styles.bgcolor,
                  labelText: 'Governorate',
                  labelStyle: TextStyle(color: Styles.textColor),
                  hintStyle: TextStyle(color: Styles.textColor),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: CouncilmembersController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Styles.primaryColor),
                      ),
                      filled: true,
                      fillColor: Styles.bgcolor,
                      labelText: 'council members',

                      labelStyle: TextStyle(color: Styles.textColor),
                      hintStyle: TextStyle(color: Styles.textColor),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: SizedBox(
                    width: double.infinity, // Make the button take up full width
                    child:ElevatedButton(
                      onPressed: () async {
                        bool status = false;
                        String formattedDate =
                            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

                        // Check if election already exists
                        CollectionReference electionCol = FirebaseFirestore.instance.collection("election");
                        QuerySnapshot electionSnapshot = await electionCol
                            .where('name', isEqualTo: name.text)
                            .where('Governorate', isEqualTo: selectedGov)
                            .get();

                        // Check if city already exists
                        CollectionReference CitiesCol = FirebaseFirestore.instance.collection("Cities");
                        QuerySnapshot citySnapshot = await CitiesCol
                            .where('name', isEqualTo: name.text)
                            .where('Governorate', isEqualTo: selectedGov)
                            .get();

                        if (electionSnapshot.docs.isEmpty && citySnapshot.docs.isEmpty) {
                          // Add document to the election collection
                          DocumentReference electionDocRef = await electionCol.add({
                            'name': name.text,
                            'population': population.text,
                            'dateofcreation': formattedDate,
                            'status': status,
                            'Governorate': selectedGov,
                          });

                          // Add document to the Cities collection
                          await CitiesCol.add({
                            'name': name.text,
                            'population': population.text,
                            'dateofcreation': formattedDate,
                            'status': status,
                            'Governorate': selectedGov,
                            'election': electionDocRef,
                            'Council members': CouncilmembersController.text,
                          });

                          // Clear input fields
                          name.clear();
                          population.clear();
                          CouncilmembersController.clear();
                          selectedGov = governorates.first;

                          // Optionally show a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Election and City added successfully')),
                          );
                        } else {
                          // Optionally show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Election and City already exists')),
                          );
                        }
                      },
                      child: Text(
                        'Add Election',
                        style: TextStyle(color: Styles.HomeTitle),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.primaryColor,
                      ),
                    )


                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



//   void uploadImage() async {
//     try {
//       if (_image == null) {
//         // Handle if no image is selected
//         return;
//       }
//
//       FirebaseStorage storage =
//       FirebaseStorage.instanceFor(bucket: 'gs://adminielect.appspot.com');
//       Reference ref = storage.ref().child(path.basename(_image!.path));
//
//       await ref.putFile(_image!);
//       String imageUrl = await ref.getDownloadURL();
//       print("/////////////////url///////////////////////  $url");
//       setState(() {
//         url = imageUrl;
//       });
//     }catch(error){
// ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Some error occured//////////////////////////// $error')));
//     }
  }

