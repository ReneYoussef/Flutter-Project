import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../Utils/AppStyles.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  // late HomePageModel _model;
  String? userId;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _getSuffix(int position) {
    if (position % 10 == 1 && position % 100 != 11) {
      return 'st';
    } else if (position % 10 == 2 && position % 100 != 12) {
      return 'nd';
    } else if (position % 10 == 3 && position % 100 != 13) {
      return 'rd';
    } else {
      return 'th';
    }
  }

  /////////////////////////////////////////////////////////////////////////////////
  String? currentUserDisplayName;
  String? currentUserDisplayCity;
  String? currentUserDisplayRole;
  String? currentUserPopulation;
  String? currentUserGovernorate;
  String? currentUserStatus;
  String? currentUserDisplayimage;
  int candidatesCountInUserVillage = 0;
  int? totalCandidates;
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    getTotalCandidatesCount();
    fetchTotalCandidates();
    getElectionData();
  }

  Future<void> fetchTotalCandidates() async {
    totalCandidates = await getTotalCandidatesCount();
    setState(() {});
  }

  Future<int> getTotalCandidatesCount() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      String userVillage = await getUserVillage();

      QuerySnapshot candidatesSnapshot = await FirebaseFirestore.instance
          .collection('candidates')
          .where('Candidate Village', isEqualTo: userVillage)
          .get();

      int candidatesCount = candidatesSnapshot.size;

      return candidatesCount;
    }

    return 0;
  }

  Future<String> getUserVillage() async {
    String userVillage = '';

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot votersSnapshot = await FirebaseFirestore.instance
            .collection('Voters_data')
            .doc(user.uid)
            .get();

        DocumentSnapshot candidatesSnapshot = await FirebaseFirestore.instance
            .collection('candidates')
            .doc(user.uid)
            .get();

        if (votersSnapshot.exists) {
          userVillage = votersSnapshot['Voter Village'] ?? '';
        } else if (candidatesSnapshot.exists) {
          userVillage = candidatesSnapshot['Candidate Village'] ?? '';
        }
      } catch (error) {
        print('Error fetching user village: $error');
      }
    }

    return userVillage;
  }

  Future<void> getCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot votersSnapshot = await FirebaseFirestore.instance
          .collection('Voters_data')
          .doc(user.uid)
          .get();

      DocumentSnapshot candidatesSnapshot = await FirebaseFirestore.instance
          .collection('candidates')
          .doc(user.uid)
          .get();

      if (votersSnapshot.exists) {
        setState(() {
          currentUserDisplayName = votersSnapshot['Name'];
          currentUserDisplayCity = votersSnapshot['Voter Village'];
          currentUserDisplayRole = votersSnapshot['role'];
          currentUserDisplayimage = votersSnapshot['imagelink'];
        });
      } else if (candidatesSnapshot.exists) {
        setState(() {
          currentUserDisplayName = candidatesSnapshot['Name'];
          currentUserDisplayCity = candidatesSnapshot['Candidate Village'];
          currentUserDisplayRole = candidatesSnapshot['role'];
          currentUserDisplayimage = candidatesSnapshot['imagelink'];
        });
      }
    }
  }

  // get election information
  Future<void> getElectionData() async {
    if (currentUserPopulation != null &&
        currentUserGovernorate != null &&
        currentUserStatus != null) {
      return;
    }

    String userVillage = await getUserVillage();

    if (userVillage.isNotEmpty) {
      try {
        QuerySnapshot electionSnapshot =
            await FirebaseFirestore.instance.collection('election').get();

        for (DocumentSnapshot electionDoc in electionSnapshot.docs) {
          if (electionDoc['name'] == userVillage) {
            setState(() {
              currentUserStatus = electionDoc['status'].toString();
            });

            await fetchGovernorateAndPopulation(userVillage);
            return;
          }
        }

        setState(() {
          currentUserStatus = 'N/A';
        });
      } catch (error) {
        print('Error fetching election data: $error');
      }
    }
  }

  Future<void> fetchGovernorateAndPopulation(String userVillage) async {
    try {
      QuerySnapshot citySnapshot = await FirebaseFirestore.instance
          .collection('Cities')
          .where('name', isEqualTo: userVillage)
          .get();

      if (citySnapshot.docs.isNotEmpty) {
        DocumentSnapshot cityDoc = citySnapshot.docs.first;

        setState(() {
          currentUserGovernorate = cityDoc['Governorate'];
          currentUserPopulation = cityDoc['population'];
        });
      } else {
        setState(() {
          currentUserGovernorate = 'N/A';
          currentUserPopulation = 'N/A';
        });
      }
    } catch (error) {
      print('Error fetching governorate and population data: $error');
    }
  }

  // get the number of coucil members in the user City according to its name
  Stream<int> getUsersVillageCouncilMembers(String userVillage) {
    return FirebaseFirestore.instance
        .collection('Cities')
        .snapshots()
        .map((snapshot) {
      int councilMembersCount = 0;
      snapshot.docs.forEach((doc) {
        Map<String, dynamic>? cityData = doc.data() as Map<String, dynamic>?;
        if (cityData != null && cityData['name'] == userVillage) {
          councilMembersCount =
              int.tryParse(cityData['Council members'].toString()) ?? 0;
        }
      });
      return councilMembersCount;
    });
  }

// to get the top candidates (ranking system)
  // Function to get the top candidates for the user's village
  Future<List<Map<String, dynamic>>> getTopCandidatesForUser() async {
    String userVillage = await getUserVillage();

    try {
      int councilMembersCount =
          await getUsersVillageCouncilMembers(userVillage).first;

      QuerySnapshot votesSnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('City', isEqualTo: userVillage)
          .get();

      QuerySnapshot votesListsSnapshot = await FirebaseFirestore.instance
          .collection('votes_lists')
          .where('City', isEqualTo: userVillage)
          .get();

      Map<String, int> candidateVotes = {};

      votesSnapshot.docs.forEach((doc) {
        final String candidateName = doc['candidateName'];
        candidateVotes[candidateName] =
            (candidateVotes[candidateName] ?? 0) + 1;
      });

      votesListsSnapshot.docs.forEach((doc) {
        final String candidateName = doc['candidateName'];
        candidateVotes[candidateName] =
            (candidateVotes[candidateName] ?? 0) + 1;
      });

      List<Map<String, dynamic>> topCandidates =
          candidateVotes.entries.map((entry) {
        return {
          'candidateName': entry.key.substring(0, 1).toUpperCase() +
              entry.key.substring(1).toLowerCase(),
          'totalVotes': entry.value,
        };
      }).toList();

      topCandidates.sort((a, b) => b['totalVotes'].compareTo(a['totalVotes']));

      return topCandidates.take(councilMembersCount).toList();
    } catch (error) {
      print('Error fetching top candidates: $error');
      return [];
    }
  }

  ///////////////////////////////////////

  double _calculateProgress(int totalVoters, int totalVotes) {
    if (totalVotes == 0) {
      return 0.0;
    }
    double progress = totalVoters / totalVotes;
    return progress;
  }

  Future<double> calculateElectionProgress() async {
    try {
      // Get the total number of voters and votes
      int totalVoters = await getVotersCount();
      int totalVotes = await getVotesCount();

      // Calculate the progress
      double progress = _calculateProgress(totalVoters, totalVotes);

      // Clamp the progress between 0.0 and 1.0
      progress = progress.clamp(0.0, 1.0);

      return progress;
    } catch (error) {
      print('Error calculating election progress: $error');
      return 0.0; // Return 0.0 in case of error
    }
  }

  Future<int> getCandidatesCount() async {
    String userVillage = await getUserVillage();
    QuerySnapshot querySnapshot6 = await FirebaseFirestore.instance
        .collection('candidates')
        .where('Candidate Village', isEqualTo: userVillage)
        .get();

    int totalcandidate = querySnapshot6.docs.length;
    print('[[[[[[[[[[[[[[[total candidates $totalcandidate]]]]]]]]]]]]]]]');
    return totalcandidate;
  }

  Future<int> getVotersCount() async {
    String userVillage = await getUserVillage();
    QuerySnapshot querySnapshot7 = await FirebaseFirestore.instance
        .collection('Voters_data')
        .where('Voter Village', isEqualTo: userVillage)
        .get();
    int totalVoters = querySnapshot7.docs.length;
    print('[[[[[[[[[[[[[[[total voters: $totalVoters]]]]]]]]]]]]]]]');

    return totalVoters;
  }

  Future<int> getVotesCount() async {
    String userVillage = await getUserVillage();
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('votes')
        .where('City', isEqualTo: userVillage)
        .get();
    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('votes_lists')
        .where('City', isEqualTo: userVillage)
        .get();

    final totalVotes = querySnapshot1.docs.length + querySnapshot2.docs.length;
    print('[[[[[[[[[[[[[[[$totalVotes]]]]]]]]]]]]]]]');
    return totalVotes;
  }

/////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.primaryBackground,
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/electiondashboard.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.55), BlendMode.dstATop),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          blurRadius: 15,
                          spreadRadius: 5,
                          color: Colors.black45.withOpacity(0.3))
                    ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(22),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    currentUserDisplayName != null
                                        ? currentUserDisplayName!
                                                .substring(0, 1)
                                                .toUpperCase() +
                                            currentUserDisplayName!.substring(1)
                                        : 'Loading...',
                                    style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        // Add more text style properties as needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  currentUserDisplayRole != null
                                      ? currentUserDisplayRole!
                                              .substring(0, 1)
                                              .toUpperCase() +
                                          currentUserDisplayRole!.substring(1)
                                      : 'Loading...',
                                  style: GoogleFonts.adventPro(
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      // Add more text style properties as needed
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                currentUserDisplayimage != null &&
                                        currentUserDisplayimage!.isNotEmpty
                                    ? SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            border: Border.all(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: Image.network(
                                              currentUserDisplayimage!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return ClipOval(
                                                  child: Opacity(
                                                    opacity:
                                                        0.66, // Adjust the opacity as needed
                                                    child: Image.asset(
                                                      'assets/image/WhatsApp Image 2024-05-22 at 15.38.03_4b400454.jpg',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.blue,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              width: 2,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor: Colors
                                                .transparent, // Set to transparent to avoid overlapping colors
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/image/WhatsApp Image 2024-05-22 at 15.38.03_4b400454.jpg',
                                                fit: BoxFit.cover,
                                              ),
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
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.79,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: 390,
                          height: 100,

                          decoration: BoxDecoration(

                            color: Color(0x00A5A1A1),

                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              currentUserDisplayCity != null
                                                  ? currentUserDisplayCity!
                                                      .substring(0)
                                                      .toUpperCase()
                                                  : 'Loading...',
                                              style: GoogleFonts.roboto(
                                                textStyle: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.white,
                                                      blurRadius: 19,
                                                      offset: Offset(1,
                                                          2), // Adjust the offset as needed
                                                    ),
                                                  ],
                                                  // Add more text style properties as needed
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              ' Election Dashboard ',
                                              style: GoogleFonts.roboto(
                                                textStyle: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.white,
                                                      blurRadius: 19,
                                                      offset: Offset(1,
                                                          1), // Adjust the offset as needed
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ]),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Center(
                              child: MasonryGridView.builder(
                                gridDelegate:
                                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                itemCount: 2,
                                itemBuilder: (context, index) {
                                  return [
                                    () => Container(
                                          height: 330,
                                          decoration: BoxDecoration(
                                            color: Color(0x76999797),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.primaryText,
                                            ),

                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        currentUserDisplayCity !=
                                                                null
                                                            ? currentUserDisplayCity!
                                                                    .substring(
                                                                        0, 1)
                                                                    .toUpperCase() +
                                                                currentUserDisplayCity!
                                                                    .substring(
                                                                        1)
                                                            : 'Loading...',
                                                        style:
                                                            GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        ' Candidates ',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.roboto(
                                                          textStyle: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${totalCandidates ?? "Loading..."}',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  textStyle: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black,
                                                thickness: 1,
                                              ),
                                              StreamBuilder<int>(
                                                stream:
                                                    getUsersVillageCouncilMembers(
                                                        currentUserDisplayCity ??
                                                            ''),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Text(
                                                      'Loading...',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                      'Error: ${snapshot.error}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    int councilMembersCount =
                                                        snapshot.data ?? 0;
                                                    return Text(
                                                      'Council Members: $councilMembersCount',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                              FutureBuilder<void>(
                                                future: getElectionData(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    // Show loading indicator while fetching data
                                                    return LinearProgressIndicator();
                                                  } else if (snapshot
                                                      .hasError) {
                                                    // Handle error gracefully
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    // Data loaded successfully
                                                    print(
                                                        'Data loaded successfully');
                                                    return Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              currentUserGovernorate ??
                                                                  'N/A',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              ' Gov.',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                        Divider(
                                                          color: Colors.black,
                                                          thickness: 1,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Election Status: ${currentUserStatus != null && currentUserStatus.toString().toLowerCase() == 'true' ? 'Online' : 'Offline'}',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle: TextStyle(
                                                                fontSize: 21,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Divider(
                                                          color: Colors.black,
                                                          thickness: 1,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      currentUserDisplayCity !=
                                                                              null
                                                                          ? currentUserDisplayCity!.substring(0, 1).toUpperCase() +
                                                                              currentUserDisplayCity!.substring(1)
                                                                          : 'Loading...',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      ' Population :',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w600),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          ' ${currentUserPopulation ?? 'N/A'}',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600
                                                                // Add more text style properties as needed
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                    () => Container(
                                          width: 136,
                                          height: 330,
                                          decoration: BoxDecoration(
                                            color: Color(0x76999797),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.primaryText,
                                            ),
                                          ),
                                          child: Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Column(
                                                children: [
                                                  FutureBuilder<
                                                      List<
                                                          Map<String,
                                                              dynamic>>>(
                                                    future: () async {
                                                      return getTopCandidatesForUser();
                                                    }(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Center(
                                                            child:
                                                                CircularProgressIndicator());
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        final topCandidates =
                                                            snapshot.data as List<
                                                                Map<String,
                                                                    dynamic>>;
                                                        if (topCandidates
                                                            .isEmpty) {
                                                          return Center(
                                                            child: Text(
                                                                ' \t\t\t No Candidates Results found for village $currentUserDisplayCity. '),
                                                          );
                                                        } else {
                                                          return ListView
                                                              .builder(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                topCandidates
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final candidate =
                                                                  topCandidates[
                                                                      index];
                                                              final candidateName =
                                                                  candidate[
                                                                          'candidateName']
                                                                      as String;
                                                              final totalVotes =
                                                                  candidate[
                                                                          'totalVotes']
                                                                      as int;
                                                              final position =
                                                                  index + 1;

                                                              String
                                                                  positionLabel;
                                                              switch (
                                                                  position) {
                                                                case 1:
                                                                  positionLabel =
                                                                      '1st';
                                                                  break;
                                                                case 2:
                                                                  positionLabel =
                                                                      '2nd';
                                                                  break;
                                                                case 3:
                                                                  positionLabel =
                                                                      '3rd';
                                                                  break;
                                                                default:
                                                                  positionLabel =
                                                                      '$position${_getSuffix(position)}';
                                                              }

                                                              return ListTile(
                                                                title: Text(
                                                                  '$positionLabel - $candidateName \n- Total Votes: $totalVotes',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        }
                                                      } else {
                                                        return Text(
                                                            'No candidates found.');
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  ][index]();
                                },
                              ),
                            ),
                          ),
                        ),

                        FutureBuilder<int>(
                          future: getVotersCount(),
                          builder: (context, voteSnapshot) {
                            if (voteSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (voteSnapshot.hasError) {
                              return Text(
                                  'Error fetching vote count: ${voteSnapshot.error}');
                            }

                            return FutureBuilder<int>(
                              future: getCandidatesCount(),
                              builder: (context, candidateSnapshot) {
                                if (candidateSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (candidateSnapshot.hasError) {
                                  return Text(
                                      'Error fetching candidate count: ${candidateSnapshot.error}');
                                }

                                int candidatesCount =
                                    candidateSnapshot.data ?? 0;

                                return FutureBuilder<double>(
                                  future: calculateElectionProgress(),
                                  builder: (context, progressSnapshot) {
                                    if (progressSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (progressSnapshot.hasError) {
                                      return Text(
                                          'Error calculating election progress: ${progressSnapshot.error}');
                                    }

                                    double progressPercentage =
                                        progressSnapshot.data ?? 0.0;

                                    return CircularPercentIndicator(
                                      percent: progressPercentage,
                                      radius: 72,
                                      lineWidth: 17,
                                      animation: true,
                                      animateFromLastPercent: true,
                                      progressColor:
                                          Color(0xFA1100FF).withOpacity(0.75),
                                      backgroundColor: Colors.white30,
                                      center: Text(
                                        'Election\nProgress\n${(progressPercentage * 100).toStringAsFixed(2)}%',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
