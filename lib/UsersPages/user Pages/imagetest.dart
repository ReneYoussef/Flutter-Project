import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'Navbar.dart';

class User_election2 extends StatefulWidget {
  const User_election2({Key? key});

  @override
  State<User_election2> createState() => _User_election2State();
}

class _User_election2State extends State<User_election2> {
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  String? userId;
  String? currentUserDisplayName;
  String? currentUserDisplayCity;
  int councilMemberCount = 0;
  int selectedCandidatesCount = 0;
  Map<String, Map<String, dynamic>> checkboxStates = {};
  late ValueNotifier<int> selectedCandidatesCountNotifier;
  bool isLoadingCouncilMembers = false;
  bool hasAlreadyVotedAlertShown = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
    selectedCandidatesCountNotifier = ValueNotifier<int>(0);
    getUserId().then((id) {
      setState(() {
        userId = id;
      });
    });
  }

  @override
  void dispose() {
    selectedCandidatesCountNotifier.dispose();
    super.dispose();
  }

  Future<String?> getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  void showMaxCandidatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Maximum Candidates Reached'),
          content: Text(
              'You have already selected the maximum number of candidates.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot votersSnapshot = await FirebaseFirestore.instance
          .collection('Voters_data')
          .doc(user.uid)
          .get();

      if (votersSnapshot.exists) {
        setState(() {
          currentUserDisplayName = votersSnapshot['Name'];
          currentUserDisplayCity = votersSnapshot['Voter Village'];
        });
        setState(() {
          isLoadingCouncilMembers = true;
        });

        councilMemberCount =
        await getUsersVillageCouncilMembers(currentUserDisplayCity!);

        // Hide circular progress indicator after fetching
        setState(() {
          isLoadingCouncilMembers = false;
        });
      }
    }
  }

  Future<int> getUsersVillageCouncilMembers(String userVillage) async {
    int councilMembersCount = 0;

    try {
      QuerySnapshot citiesSnapshot =
      await FirebaseFirestore.instance.collection('Cities').get();

      citiesSnapshot.docs.forEach((doc) {
        Map<String, dynamic>? cityData = doc.data() as Map<String, dynamic>?;
        if (cityData != null && cityData['name'] == userVillage) {
          councilMembersCount =
              int.tryParse(cityData['Council members'].toString()) ?? 0;
        }
      });

      if (councilMembersCount == 0) {
        print('Council members count not found for $userVillage');
      }
    } catch (e) {
      print('Error fetching council members count: $e');
    }

    return councilMembersCount;
  }

  void updateSelectedCandidatesCount(bool value) {
    int updatedCount = selectedCandidatesCount + (value ? 1 : -1);
    if (updatedCount > councilMemberCount) {
      showMaxCandidatesDialog(context);
      return;
    }
    if (value) {
      selectedCandidatesCount++;
    } else {
      selectedCandidatesCount--;
    }
    selectedCandidatesCountNotifier.value = selectedCandidatesCount;
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return CircularProgressIndicator();
    }

    return SafeArea(
      child: Scaffold(
        body: Builder( // Use Builder to get a new context
          builder: (BuildContext scaffoldContext) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/electiondashboard.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.dstATop), // Adjust opacity here
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(

                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(22),
                            child: Row(
                              children: [
                                Text(
                                  currentUserDisplayCity ?? 'Loading...',
                                  style: GoogleFonts.damion(
                                    textStyle: TextStyle(
                                      fontSize: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  '   Individual Candidates',
                                  style: GoogleFonts.adventPro(
                                    textStyle: TextStyle(
                                        fontSize: 23,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(

                      child: Center(
                        child: Container(

                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('candidates')
                                .where('Candidate Village', isEqualTo: currentUserDisplayCity)
                                .snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Text('No candidates available for this city');
                              }

                              var candidateDocs = snapshot.data!.docs;
                              return Column(

                                children: [

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          CollectionReference votesRef = FirebaseFirestore.instance.collection('votes');
                                          CollectionReference listVotesRef = FirebaseFirestore.instance.collection('votes_lists');
                                          CollectionReference cityRef = FirebaseFirestore.instance.collection('Cities');

                                          // Get the data of all selected candidates
                                          List<Map<String, dynamic>> selectedCandidates = checkboxStates.entries
                                              .where((entry) => entry.value['value'])
                                              .map((entry) => entry.value)
                                              .toList();

                                          // Check if the user has reached the maximum number of council members
                                          if (selectedCandidates.isNotEmpty) {
                                            String villageName = selectedCandidates[0]['village'];
                                            QuerySnapshot citySnapshot = await cityRef.where('name', isEqualTo: villageName).get();

                                            if (citySnapshot.docs.isNotEmpty) {
                                              DocumentSnapshot cityDoc = citySnapshot.docs.first;
                                              int maxCouncilMembers = cityDoc['Council members'];
                                              QuerySnapshot userVoteSnapshot = await votesRef
                                                  .where('userId', isEqualTo: userId)
                                                  .where('City', isEqualTo: villageName)
                                                  .get();

                                              if (userVoteSnapshot.docs.length >= maxCouncilMembers) {
                                                _showDialog(
                                                  scaffoldContext,
                                                  'Vote Error',
                                                  'You have already voted for the maximum number of council members in $villageName!',
                                                );
                                                return;
                                              }
                                            } else {
                                              _showDialog(
                                                scaffoldContext,
                                                'Vote Error',
                                                'City document not found for $villageName!',
                                              );
                                              return;
                                            }
                                          }

                                          // Check if the user has already voted for any selected lists
                                          for (Map<String, dynamic> data in selectedCandidates) {
                                            QuerySnapshot listVotesSnapshot = await listVotesRef
                                                .where('userId', isEqualTo: userId)
                                                .where('listName', isEqualTo: data['listName'])
                                                .get();

                                            if (listVotesSnapshot.docs.isNotEmpty) {
                                              _showDialog(
                                                scaffoldContext,
                                                'Vote Error',
                                                'You have already voted for a list. You cannot vote again.',
                                              );
                                              return;
                                            }
                                          }

                                          // Check if the user has already voted for any selected candidates
                                          for (Map<String, dynamic> data in selectedCandidates) {
                                            QuerySnapshot candidateVotesSnapshot = await votesRef
                                                .where('userId', isEqualTo: userId)
                                                .where('candidateId', isEqualTo: data['candidateId'])
                                                .get();

                                            if (candidateVotesSnapshot.docs.isNotEmpty) {
                                              _showDialog(
                                                scaffoldContext,
                                                'Vote Error',
                                                'You have already voted for a candidate. You cannot vote again.',
                                              );
                                              return;
                                            }
                                          }

                                          // Show a dialog with the names of selected candidates and Vote/Cancel buttons
                                          showDialog(
                                            context: scaffoldContext,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Selected Candidates'),
                                                content: Text('You have selected: ${selectedCandidates.map((data) => data['name']).join(', ')}\n\nAre you sure you want to vote for them?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context); // Close the dialog first

                                                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Voting process started...'),
                                                        ),
                                                      );

                                                      for (Map<String, dynamic> data in selectedCandidates) {
                                                        bool canVote = await _checkElectionStatus(data['village']);
                                                        if (canVote) {
                                                          await _voteForIndividualCandidate(scaffoldContext, data['candidateId'], data['name'], data['village']);
                                                        } else {
                                                          _showDialog(
                                                            scaffoldContext,
                                                            'Cannot Vote',
                                                            'You cannot vote, this election is Offline.',
                                                          );
                                                          return;
                                                        }
                                                      }

                                                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Voting process completed.'),
                                                        ),
                                                      );
                                                    },
                                                    child: Text('Vote'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          'Submit Your Votes',
                                          style: TextStyle(color: Colors.white, fontSize: 15),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFA1100FF).withOpacity(0.75),
                                        ),
                                      ),


                                      SizedBox(width: 10,),
                                      Row(
                                        children: [
                                          ValueListenableBuilder<int>(
                                            valueListenable: selectedCandidatesCountNotifier,
                                            builder: (context, count, child) {
                                              if (councilMemberCount == null) {
                                                return CircularProgressIndicator();
                                              } else {
                                                return Row(
                                                  children: [
                                                    Text(
                                                      '${count > 0 ? count : 0}/$councilMemberCount',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                                          SizedBox(width: 8,),
                                          Icon(Icons.groups_sharp, color:  Color(
                                              0xFA1100FF).withOpacity(0.75)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: candidateDocs.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        var userData = candidateDocs[index].data() as Map<String, dynamic>;
                                        String imageUrl = userData['imagelink'] ?? ''; // Fetch the image URL from user data
                                        return Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              color: Colors.transparent,
                                              child: Card(
                                                elevation: 5,
                                                shadowColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Container(
                                                            width: 65,
                                                            height: 65,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.white,
                                                                  blurRadius: 2,
                                                                  offset: Offset(0, 0), // Adjust the offset as needed
                                                                ),
                                                              ],
                                                            ),
                                                            child: CircleAvatar(
                                                              backgroundColor: Colors.blue,
                                                              backgroundImage: imageUrl.isNotEmpty
                                                                  ? NetworkImage(imageUrl)
                                                                  : AssetImage('assets/image/placeholder_image.jpg') as ImageProvider, // Cast to ImageProvider
                                                            ),
                                                          ),
                                                          SizedBox(width: 5),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(
                                                                userData['Name'] ?? '',
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text('Age: '),
                                                                  Text(userData['Age'].toString() ?? ''),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    userData['Candidate Village'] ?? '',
                                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                                  ),
                                                                  Text('  List: '),
                                                                  Text(userData['list'] ?? ''),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      StatefulBuilder(
                                                        builder: (context, setState) {
                                                          return Container(
                                                            alignment: Alignment.center,
                                                            child: Row(
                                                              children: [
                                                                Checkbox(
                                                                  value: checkboxStates[userData['Name']]?['value'] ?? false,
                                                                  onChanged: (value) {
                                                                    if (value! && selectedCandidatesCount >= councilMemberCount) {
                                                                      showMaxCandidatesDialog(context);
                                                                      return;
                                                                    }
                                                                    setState(() {
                                                                      checkboxStates[userData['Name']] = {
                                                                        'value': value,
                                                                        'name': userData['Name'] ?? '',
                                                                        'village': userData['Candidate Village'] ?? '',
                                                                        'candidateId': candidateDocs[index].id,
                                                                      };
                                                                      updateSelectedCandidatesCount(value);
                                                                    });
                                                                  },
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                  activeColor: Color(0xFA1100FF).withOpacity(0.75),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _voteForIndividualCandidate(BuildContext context,
      String candidateId, String candidateName, String villageName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userId = user.uid;
      CollectionReference votesRef =
      FirebaseFirestore.instance.collection('votes');
      CollectionReference listVotesRef =
      FirebaseFirestore.instance.collection('votes_lists');
      CollectionReference cityRef =
      FirebaseFirestore.instance.collection('Cities');
      BuildContext? scaffoldContext;
      if (context != null) {
        scaffoldContext = context;
      } else {
        print("Context is null.");
        return;
      }

      bool hasVotedForList = false;
      bool hasReachedMaxCouncilMembers = false;
      bool hasCityDocumentError = false;
      bool hasFailedToCreateVote = false;

      try {
        QuerySnapshot listVotesSnapshot =
        await listVotesRef.where('userId', isEqualTo: userId).get();
        if (listVotesSnapshot.docs.isNotEmpty && !hasVotedForList) {
          hasVotedForList = true;
          showDialog(
            context: scaffoldContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Vote Error'),
                content: Text('You have already voted for a list!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        QuerySnapshot candidateVotesSnapshot = await votesRef
            .where('userId', isEqualTo: userId)
            .where('candidateId', isEqualTo: candidateId)
            .get();
        if (candidateVotesSnapshot.docs.isNotEmpty) {
          showDialog(
            context: scaffoldContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Vote Error'),
                content: Text('You have already voted for $candidateName!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        QuerySnapshot citySnapshot =
        await cityRef.where('name', isEqualTo: villageName).get();

        if (citySnapshot.docs.isNotEmpty) {
          DocumentSnapshot cityDoc = citySnapshot.docs.first;
          int maxCouncilMembers = cityDoc['Council members'];
          QuerySnapshot userVoteSnapshot = await votesRef
              .where('userId', isEqualTo: userId)
              .where('City', isEqualTo: villageName)
              .get();

          if (userVoteSnapshot.docs.length >= maxCouncilMembers &&
              !hasReachedMaxCouncilMembers) {
            hasReachedMaxCouncilMembers = true;
            showDialog(
              context: scaffoldContext!,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Vote Error'),
                  content: Text(
                    'You have already voted for the maximum number of council members in $villageName!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
            return;
          }
        } else if (!hasCityDocumentError) {
          hasCityDocumentError = true;
          showDialog(
            context: scaffoldContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Vote Error'),
                content: Text(
                  'City document not found for $villageName!',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        await votesRef.add({
          'userId': userId,
          'candidateId': candidateId,
          'City': villageName,
          'candidateName': candidateName,
        });
      } catch (error) {
        if (!hasFailedToCreateVote) {
          hasFailedToCreateVote = true;
          showDialog(
            context: scaffoldContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Vote Error'),
                content: Text('Failed to create vote: $error'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Future<bool> _checkElectionStatus(String villageName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('election')
          .where('name', isEqualTo: villageName)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        bool? status = querySnapshot.docs.first['status'];
        return status != null && status;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking election status: $e');
      return false;
    }
  }
}
