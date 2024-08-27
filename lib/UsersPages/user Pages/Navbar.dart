import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Candidate_election.dart';
import 'Dashboard.dart';
import 'ListPage.dart';
import 'User_Account.dart';
import 'User_election.dart';
import 'candListpage.dart';

class UserNavbar extends StatefulWidget {
  const UserNavbar({Key? key}) : super(key: key);

  @override
  UserNavbarState createState() => UserNavbarState();
}

class UserNavbarState extends State<UserNavbar> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomePageWidget(),
      User_election(),
      User_Account(),
      Candidate_election(),
      Candidatelistpage(),
    ];
  }

  //method for dynamic menu items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isCandidateUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is still loading, return a loading indicator
          return Center(
            child: Container(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 2.3,
                strokeAlign: 2,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // If an error occurs, display an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future has completed successfully, build the appropriate widget list based on the user's role
          bool isCandidate = snapshot.data ?? false;
          if (isCandidate) {
            _widgetOptions = [
              HomePageWidget(),
              Candidate_election(),
              Candidatelistpage(),// Use Candidate_election instead of User_election
              User_Account(),
            ];
          } else {
            _widgetOptions = [
              HomePageWidget(),
              User_election(),
              VoterLists(),
              User_Account(),
            ];
          }
          // Return the Scaffold with the updated widget options
          return Scaffold(
            body: Center(
              child: _widgetOptions[_selectedIndex],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              elevation: 10,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.blueGrey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.how_to_vote_outlined),
                  activeIcon: Icon(Icons.how_to_vote_rounded),
                  label: "Your Election",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_outlined),
                  activeIcon: Icon(Icons.list_alt_rounded),
                  label: "Candiates Lists",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  activeIcon: Icon(Icons.account_circle),
                  label: "Account",
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<bool> isCandidateUser() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      DocumentSnapshot voterDoc = await FirebaseFirestore.instance
          .collection('Voters_data')
          .doc(user.uid)
          .get();
      DocumentSnapshot candDoc = await FirebaseFirestore.instance
          .collection('candidates')
          .doc(user.uid)
          .get();

      String? role = voterDoc.exists ? voterDoc['role'] : null;

      bool isCandidate = candDoc.exists;
      bool isVoter = voterDoc.exists;

      return (isCandidate || role == 'candiadte');
    } else {
      // User is not authenticated
      return false;
    }
  }
}
