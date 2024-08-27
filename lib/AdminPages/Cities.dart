
import 'package:ielect/Utils/AppStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'Adding/UpdateCity.dart';
import 'Navbar.dart';

class Cities extends StatefulWidget {
  const Cities({Key? key}) : super(key: key);

  @override
  State<Cities> createState() => _AddCitiesState();
}

class _AddCitiesState extends State<Cities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cities'),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Cities')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: Container(
                                  child: Text(
                                    'No cities at the moment. Please create an election, and automatically the city will be added',
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: List.generate(
                                (snapshot.data!.docs.length / 2).ceil(),
                                    (index) {
                                  int startIndex = index * 2;
                                  int endIndex = startIndex + 2;
                                  if (endIndex > snapshot.data!.docs.length) {
                                    endIndex = snapshot.data!.docs.length;
                                  }
                                  return Row(
                                    children: snapshot.data!.docs
                                        .sublist(startIndex, endIndex)
                                        .map(
                                          (document) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigate to a page to update the data for the selected city
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => UpdateCity(
                                                    cityDocument: document,
                                                    cityName: document['name'], // Pass the city name
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        document['name'],
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 12,
                                                      ),
                                                      Icon(Icons.group),
                                                      Text(
                                                        document['population'],
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Image.asset(
                                                    'assets/image/OIP2.jpeg',
                                                    width: 180,
                                                    height: 90,
                                                    fit: BoxFit.fill,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        document[
                                                        'dateofcreation'],
                                                      ),
                                                      SizedBox(width: 35),
                                                      StreamBuilder<
                                                          DocumentSnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection('Cities')
                                                            .doc(
                                                            document.id)
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                              .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return CircularProgressIndicator();
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Text(
                                                                'Error: ${snapshot.error}');
                                                          } else {
                                                            bool status =
                                                                snapshot.data![
                                                                'status'] ??
                                                                    false;
                                                            Color iconColor =
                                                            status
                                                                ? Colors
                                                                .green
                                                                : Colors
                                                                .red;
                                                            IconData iconData =
                                                            status
                                                                ? Icons
                                                                .circle
                                                                : Icons
                                                                .circle;
                                                            return Icon(
                                                              iconData,
                                                              size: 20,
                                                              color:
                                                              iconColor,
                                                              shadows: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                      0.5),
                                                                  blurRadius:
                                                                  3,
                                                                  offset:
                                                                  Offset(
                                                                      1, 3),
                                                                )
                                                              ],
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        .toList(),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}

