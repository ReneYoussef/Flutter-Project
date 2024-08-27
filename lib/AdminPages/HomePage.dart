import 'dart:convert';

import 'package:ielect/AdminPages/Cities.dart';
import 'package:ielect/AdminPages/FinalResults.dart';
import 'package:ielect/AdminPages/elections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils/AppStyles.dart';
import 'TotalParticipants.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.97,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset(
              'assets/image/OIP2.jpeg',
            ).image,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
              spreadRadius: 100,
            )
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 502,
                    height: 194,
                    decoration: const BoxDecoration(
                      color: Color(0x00FFFFFF),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0, 1),
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  'DashBoard',
                                  style: Styles.headlinestyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: Text(
                                '    Lebanese Municipality Election',
                                textAlign: TextAlign.center,
                                style: Styles.headlinestyle2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(
                flex: 3,
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<int>(
                      future: getVoterssCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TotalParticipants()),
                              );
                            },
                            child: Container(
                              width: 135,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Styles.HomeContainerbgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0x6C5E5F60),
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Voters',
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: Text(
                                      '${snapshot.data ?? 0}', // Display the count from the snapshot
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    FutureBuilder<int>(
                      future: getCandidatesCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TotalParticipants()),
                              );
                            },
                            child: Container(
                              width: 135,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Styles.HomeContainerbgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0x6C5E5F60),
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Candidates',
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: Text(
                                      '${snapshot.data ?? 0}', // Display the count from the snapshot
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<int>(
                      future: getCitiesCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Cities()),
                              );
                            },
                            child: Container(
                              width: 135,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Styles.HomeContainerbgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0x6C5E5F60),
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Cities',
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: Text(
                                      '${snapshot.data ?? 0}', // Display the count from the snapshot
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    FutureBuilder<int>(
                      future: getElectionsCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Elections()),
                              );
                            },
                            child: Container(
                              width: 135,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Styles.HomeContainerbgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0x6C5E5F60),
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Elections',
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: Text(
                                      '${snapshot.data ?? 0}', // Display the count from the snapshot
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<int>(
                      future: getVotesCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => finalresult()),
                              );
                            },
                            child: Container(
                              width: 135,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Styles.HomeContainerbgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0x6C5E5F60),
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Total Votes',
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0, 1),
                                    child: Text(
                                      '${snapshot.data ?? 0}', // Display the total votes count from the snapshot
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle
                                          .copyWith(color: Styles.HomeTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    FutureBuilder<Map<String, dynamic>>(
                      future: getTopVotersCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          final city = snapshot.data!['city'];
                          final count = snapshot.data!['count'];
                          return Container(
                            width: 135,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Styles.HomeContainerbgColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0x6C5E5F60),
                                width: 3,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'City with top Voters',
                                    textAlign: TextAlign.center,
                                    style: Styles.textStyle.copyWith(color: Styles.HomeTitle),
                                  ),
                                ),
                                Text(
                                  '$city: $count voters',
                                  textAlign: TextAlign.center,
                                  style: Styles.textStyle.copyWith(color: Styles.HomeTitle),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text('No data available');
                        }
                      },
                    )
                  ],
                ),
              ),
              const Spacer(
                flex: 2,
              )
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////Function////////////////////////////////////

  Future<int> getCitiesCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Cities').get();
    return querySnapshot.docs.length;
  }

  Future<int> getCandidatesCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('candidates').get();
    return querySnapshot.docs.length;
  }


  Future<Map<String, dynamic>> getTopVotersCount() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final votersSnapshot = await _firestore.collection('Voters_data').get();
    final citiesSnapshot = await _firestore.collection('Cities').get();

    String cityWithMostVoters = '';
    int highestVoterCount = 0;

    for (var cityDoc in citiesSnapshot.docs) {
      int voterCount = 0;
      String cityName = cityDoc['name'];

      for (var voterDoc in votersSnapshot.docs) {
        if (voterDoc['Voter Village'] == cityName) {
          voterCount++;
        }
      }

      if (voterCount > highestVoterCount) {
        highestVoterCount = voterCount;
        cityWithMostVoters = cityName;
      }
    }

    if (cityWithMostVoters.isEmpty) {
      throw Exception('No data found');
    }

    return {
      'city': cityWithMostVoters,
      'count': highestVoterCount,
    };
  }


  Future<int> getVoterssCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Voters_data').get();
    return querySnapshot.docs.length;
  }

  Future<int> getElectionsCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('election').get();
    return querySnapshot.docs.length;
  }

  Future<int> getVotesCount() async {
    try {
      QuerySnapshot votesQuerySnapshot =
          await FirebaseFirestore.instance.collection('votes').get();
      QuerySnapshot votesListsQuerySnapshot =
          await FirebaseFirestore.instance.collection('votes_lists').get();

      int votesCount =
          votesQuerySnapshot.docs.length + votesListsQuerySnapshot.docs.length;

      return votesCount;
    } catch (e) {
      print('Error fetching votes count: $e');
      throw e;
    }
  }
  //////////////////////////////////////////////////////////////////////////////
}
