import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VillageDetailScreen extends StatelessWidget {
  final String villageName;

  VillageDetailScreen({required this.villageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(villageName),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getVillageData(villageName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            final Map<String, dynamic> villageData = snapshot.data!;
            final int totalVotes = villageData['totalVotes'];
            final List<dynamic> candidates = villageData['candidates'];

            return Container(
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Total Votes: $totalVotes',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Candidates:',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: candidates.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              border: Border.all(
                             color: Colors.black, width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15),

                            ),
                            child: ListTile(
                              title: Text(candidates[index]['candidateName'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              subtitle: Text('Votes: ${candidates[index]['votes']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                ],
              ),
            );
          } else {
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getVillageData(String villageName) async {
    try {

      final QuerySnapshot votesQuerySnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('City', isEqualTo: villageName)
          .get();

      final QuerySnapshot votesListsQuerySnapshot = await FirebaseFirestore.instance
          .collection('votes_lists')
          .where('City', isEqualTo: villageName)
          .get();

      final int totalVotes = votesQuerySnapshot.size + votesListsQuerySnapshot.size;

      Map<String, int> candidateVotes = {};

      votesQuerySnapshot.docs.forEach((doc) {
        final candidateName = doc['candidateName'];
        // Increment the vote count for the candidate
        candidateVotes[candidateName] = (candidateVotes[candidateName] ?? 0) + 1;
      });

      votesListsQuerySnapshot.docs.forEach((doc) {
        final candidateName = doc['candidateName'];

        candidateVotes[candidateName] = (candidateVotes[candidateName] ?? 0) + 1;
      });

      List<Map<String, dynamic>> candidates = [];
      candidateVotes.forEach((candidateName, votes) {
        candidates.add({'candidateName': candidateName, 'votes': votes});
      });

      candidates.sort((a, b) => b['votes'].compareTo(a['votes']));

      return {
        'totalVotes': totalVotes,
        'candidates': candidates,
      };
    } catch (e) {
      print('Error fetching village data: $e');
      throw e;
    }
  }



}
