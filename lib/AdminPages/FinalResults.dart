
import 'package:ielect/AdminPages/villagedetailscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Navbar.dart';

class finalresult extends StatefulWidget {
  const finalresult({Key? key});

  @override
  State<finalresult> createState() => _finalresultState();
}

class _finalresultState extends State<finalresult> {

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cities Results'),
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
      body: Container(
        margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
            FutureBuilder<List<String>>(
              future: getVillages(),
              builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    final List<String> villages = snapshot.data!;
                    return Column(
                      children: villages.map((villageName) {
                        return ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 75,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      villageName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        wordSpacing: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10), // Adjust the spacing between the text and the switch

                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VillageDetailScreen(
                                  villageName: villageName,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  } else {
                    return Text('No data found.');
                  }
                },
              )],
          ),
        ),
      ),
    );
  }

//this function can fetch all the villages According to the Candidates that are in collection candiadtes
  Future<List<String>> getVillages() async {
    final QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('candidates').get();
    final List<String> villages = querySnapshot.docs
        .map((doc) => doc['Candidate Village'] as String)
        .toSet()
        .toList();
    return villages;
  }


}
