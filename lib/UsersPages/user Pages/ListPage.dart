import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VoterLists extends StatefulWidget {
  const VoterLists({Key? key});

  @override
  State<VoterLists> createState() => _VoterListsState();
}

class _VoterListsState extends State<VoterLists> {
  late List<DocumentSnapshot> voterDocs;
  String? VoterVillage;
  Map<String, dynamic> candidateData = {};
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId().then((id) {
      setState(() {
        userId = id;
      });
    });
  }

  Future<String?> getUserId() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    print('$user///////////////////////////////////////////////////');
    // If user is not null, return the user ID
    if (user != null) {
      print(
          '666666666666666666666666///$user///////////////////////////////////////////////////');
      return user.uid;
    } else {
      return null;
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchCandidatesGroupedByList() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    if (uid != null) {
      // Fetch voter data for the current user
      final voterData = await FirebaseFirestore.instance
          .collection('Voters_data')
          .doc(uid)
          .get();

      // Extract village information from the voter's document
      final dynamic VoterVillage = voterData.data()?['Voter Village'];
      if (VoterVillage != null) {
        this.VoterVillage = VoterVillage is List ? VoterVillage.first : VoterVillage.toString();
      }

      print('Candidate Village: $VoterVillage');

      // Use the candidate's village name for election status checking
      return _fetchCandidatesWithVillage(this.VoterVillage ?? '');
    } else {
      // Handle the case where user ID is null
      return {};
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchCandidatesWithVillage(String VoterVillage) async {
    // Query candidates with matching villages
    final snapshot = await FirebaseFirestore.instance
        .collection('candidates')
        .where('Candidate Village', isEqualTo: VoterVillage)
        .get();
    final candidates = snapshot.docs.map((doc) => doc.data()).toList();
    print('Candidate Village: $candidates');
    // Group candidates by their list
    final Map<String, List<Map<String, dynamic>>> groupedCandidates = {};

    candidates.forEach((candidate) {
      final list = candidate['list'] as String;
      if (!groupedCandidates.containsKey(list)) {
        groupedCandidates[list] = [];
      }
      groupedCandidates[list]!.add(candidate);
    });

    return groupedCandidates;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: fetchCandidatesGroupedByList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final groupedCandidates = snapshot.data as Map<String, List<Map<String, dynamic>>>;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Background image
              Image.asset(
                'assets/image/electiondashboard.jpg', // Replace 'assets/background_image.jpg' with your actual image path
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // Main content
              CarouselSlider(
                options: CarouselOptions(height: 600.0), // Set the height of the slider
                items: groupedCandidates.entries.map((entry) {
                  final listName = entry.key;
                  final candidates = entry.value;

                  return Builder(
                    builder: (BuildContext context) {
                      return Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              height: 500, // Adjust the height as needed
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: candidates.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0) {
                                    // This is the first item, which is the list title
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 19),
                                      child: Container(
                                        color: Colors.white,
                                        width: MediaQuery.of(context).size.width * 0.5,

                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(width: 5),
                                            Text(
                                              '$listName',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              margin: EdgeInsets.all(3),
                                              width: 80,
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final bool canVote = await checkElectionAndVote(VoterVillage, candidates, listName);
                                                  print('////////$canVote///////////////////////////////////////////// ');

                                                  if (canVote) {
                                                    _voteForIndividualList(candidates, listName, VoterVillage ?? '');
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text('Cannot Vote'),
                                                          content: Text('You cannot vote this election is offline.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },

                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(
                                                      0xFA1100FF).withOpacity(0.75),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.how_to_vote_rounded,
                                                      color: Colors.white,

                                                    ),

                                                  ],
                                                ),

                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    // This is a candidate item
                                    final candidateData = candidates[index-1];
                                    String imageUrl = candidateData['imagelink'] ?? '';
                                    return Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(7),
                                          width: 295,

                                            color: Colors.white60.withOpacity(0.3),
                                          child: Card(
                                            elevation: 15,

                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 9),
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
                                      : AssetImage('assets/image/WhatsApp Image 2024-05-22 at 15.38.03_4b400454.jpg') as ImageProvider, // Cast to ImageProvider
                                  ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            candidateData['Name'] ?? '',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 19,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text('Age: '),
                                                              Text(candidateData['Age']?.toString() ?? ''),
                                                            ],
                                                          ),
                                                          Text(
                                                            candidateData['Candidate Village'] ?? '',
                                                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
              )
            ],
          );
        },
      ),
    );
  }

  Future<bool> checkElectionAndVote(
      String? VoterVillage,
      List<Map<String, dynamic>> candidates,
      String listName,
      ) async {
    print('Query Snapshot//////////////////////////////////////////');
    print('Query Snapshot//////////////////////////////////////////: $VoterVillage');
    print('Query Snapshot//////////////////////: $listName');
    print('Query Snapshot//////////////////////////////////////////: $candidates');
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('election')
          .where('name', isEqualTo: VoterVillage) // Check if 'name' matches the candidate village
          .get();
      print('Query Snapshot: $querySnapshot');

      if (querySnapshot.docs.isNotEmpty) {
        // Document found, check election status
        final bool status = querySnapshot.docs.first['status'];
        print('Election Status: $status');

        return status;
      } else {

        print('No matching document found');
        return false;
      }
    } catch (e) {
      print('Error checking election status: $e');
      return false;
    }
  }

  void _voteForIndividualList(List<Map<String, dynamic>> candidates, String listName, String VoterVillage) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      CollectionReference votesRef = FirebaseFirestore.instance.collection('votes_lists');
      CollectionReference individualVotesRef = FirebaseFirestore.instance.collection('votes'); // Reference to votes collection
      BuildContext? scaffoldContext;
      if (context != null) {
        scaffoldContext = context;
      } else {
        print("Context is null.");
        return;
      }
      try {

        QuerySnapshot individualVotes = await individualVotesRef
            .where('userId', isEqualTo: userId)
            .get();


        if (individualVotes.docs.isNotEmpty) {
          showDialog(
            context: scaffoldContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Vote Error'),
                content: Text('You have already voted for individual candidates!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }


        QuerySnapshot listVotes = await votesRef
            .where('userId', isEqualTo: userId)
            .get();


        if (listVotes.docs.isNotEmpty) {
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


        candidates.forEach((candidate) {

          votesRef
              .add({
            'userId': userId,
            'candidateName': candidate['Name'],
            'listName': listName,
            'City': VoterVillage,
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Vote for ${candidate['Name']} successful!',
                ),
              ),
            );
          }).catchError((error) {

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
          });
        });

        showDialog(
          context: scaffoldContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Vote Success'),
              content: Text('Voting for the $listName list successful!'),
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

      } catch (e) {

        print('Error: $e');
      }
    }
  }



}
