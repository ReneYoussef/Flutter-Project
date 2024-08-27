import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils/AppStyles.dart';
import 'Adding/AddElections.dart';
import 'Navbar.dart';

class Elections extends StatefulWidget {
  const Elections({Key? key}) : super(key: key);

  @override
  State<Elections> createState() => _ElectionsState();
}

class _ElectionsState extends State<Elections> {

  final List<bool> statuses = [];

  @override
  void initState() {
    super.initState();
    retrieveInitialStatuses();
  }

  Future<void> retrieveInitialStatuses() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('election').get();

      setState(() {
        statuses.clear();
        for (var doc in snapshot.docs) {
          statuses.add(doc['status'] ?? false);
        }
      });
    } catch (e) {
      print('Error fetching initial statuses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Election'), actions: [
        IconButton(
          icon: Icon(CupertinoIcons.trash),
          onPressed: _clearTable,
        ),
      ], leading: IconButton(
        icon: Icon(CupertinoIcons.arrow_left),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminNavbar()),
          );
        },
      )),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AddElection()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: Text(
                'Add Election',
                style: Styles.ButtonText,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('election')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: (snapshot.data!.docs.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            int startIndex = index * 2;
                            int endIndex = startIndex + 2;
                            if (endIndex > snapshot.data!.docs.length) {
                              endIndex = snapshot.data!.docs.length;
                            }
                            return Row(
                              children: List.generate(
                                endIndex - startIndex,
                                    (index) {
                                  var document =
                                  snapshot.data!.docs[startIndex + index];
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                            Text(
                                              document['name'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                              MainAxisAlignment.start,
                                              children: [
                                                Switch(
                                                  value: statuses.length > startIndex + index
                                                      ? statuses[startIndex + index]
                                                      : false,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (statuses.length > startIndex + index) {
                                                        statuses[startIndex + index] = value;
                                                      } else {
                                                        statuses.addAll(List.filled(startIndex + index - statuses.length + 1, false));
                                                        statuses[startIndex + index] = value;
                                                      }
                                                    });

                                                    updateStatusInFirestore(document['name'], value);
                                                  },
                                                ),
                                                SizedBox(width: 20),
                                                Icon(Icons.people),
                                                SizedBox(width: 5),
                                                Text(
                                                  document['population'].toString(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateStatusInFirestore(String name, bool status) async {
    try {
      CollectionReference collection =
      FirebaseFirestore.instance.collection('election');
      CollectionReference collection2 =
      FirebaseFirestore.instance.collection('Cities');

      QuerySnapshot querySnapshot =
      await collection.where('name', isEqualTo: name).get();
      QuerySnapshot querySnapshot2 =
      await collection2.where('name', isEqualTo: name).get();

      if (querySnapshot.docs.isNotEmpty && querySnapshot2.docs.isNotEmpty) {
        await collection
            .doc(querySnapshot.docs.first.id)
            .update({'status': status});
        await collection2
            .doc(querySnapshot2.docs.first.id)
            .update({'status': status});
        print('Status updated in election collection for document: $name');
      } else {
        print('Document $name does not exist in election collection.');
      }
    } catch (e) {
      print('Error updating status in election collection: $e');
    }
  }
}


void _clearTable() async {
  CollectionReference electionCollection =
  FirebaseFirestore.instance.collection('election');
  CollectionReference citiesCollection =
  FirebaseFirestore.instance.collection('Cities');

  QuerySnapshot electionSnapshot = await electionCollection.get();
  QuerySnapshot citiesSnapshot = await citiesCollection.get();


  for (var doc in electionSnapshot.docs) {
    await doc.reference.delete();
  }

  for (var doc in citiesSnapshot.docs) {
    await doc.reference.delete();
  }
}

////////////////////////////////////////////////////////////////////////////////

