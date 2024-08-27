import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Navbar.dart';

class TotalParticipants extends StatefulWidget {
  const TotalParticipants({Key? key}) : super(key: key);

  @override
  State<TotalParticipants> createState() => _TotalParticipantsState();
}

class _TotalParticipantsState extends State<TotalParticipants> {
  late Future<List<Map<String, dynamic>>> _data;

  @override
  void initState() {
    super.initState();
    _data = getData();
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final votersSnapshot = await _firestore.collection('Voters_data').get();
    final candidatesSnapshot = await _firestore.collection('candidates').get();
    final citiesSnapshot = await _firestore.collection('Cities').get();

    List<Map<String, dynamic>> data = [];

    citiesSnapshot.docs.forEach((cityDoc) {
      int voterCount = 0;
      int candidateCount = 0;
      String cityName = cityDoc['name'];

      votersSnapshot.docs.forEach((voterDoc) {
        if (voterDoc['Voter Village'] == cityName) {
          voterCount++;
        }
      });

      candidatesSnapshot.docs.forEach((candidateDoc) {
        if (candidateDoc['Candidate Village'] == cityName) {
          candidateCount++;
        }
      });

      data.add({
        'City Name': cityName,
        'Voter Count': voterCount,
        'Candidate Count': candidateCount,
      });
    });

    // Sort the data in ascending order based on the city name
    data.sort((a, b) => b['Voter Count'].compareTo(a['Candidate Count']));

    return data;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voters and Candidates Count'),
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
        width: 400,
        height: 800,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return Center(
                  child: DataTable(
                    border: TableBorder.all(width: 2, borderRadius: BorderRadius.circular(10)),
                    showBottomBorder: true,
                    headingRowColor: MaterialStateProperty.all(Colors.blue),
                    columns: [
                      DataColumn(label: Text('City Name')),
                      DataColumn(label: Text('Voters')),
                      DataColumn(label: Text('Candidates')),
                    ],
                    rows: snapshot.data!.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['City Name'])),
                        DataCell(Text(data['Voter Count'].toString())),
                        DataCell(Text(data['Candidate Count'].toString())),
                      ]);
                    }).toList(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
