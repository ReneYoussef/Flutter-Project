import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Utils/AppStyles.dart';

class UpdateCity extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> cityDocument;
  final String cityName; // Receive the city name here

  const UpdateCity({
    Key? key,
    required this.cityDocument,
    required this.cityName,
  }) : super(key: key);

  @override
  State<UpdateCity> createState() => _UpdateCityState();
}


class _UpdateCityState extends State<UpdateCity> {


  TextEditingController _cityNamecontroller = TextEditingController();
  TextEditingController _populationcontroller = TextEditingController();
  TextEditingController _councilmemberscontroller = TextEditingController();
  TextEditingController _governoratecontroller = TextEditingController();
  List<String> governorates = [
    'Akkar',
    'Baalbek-Hermel',
    'Beirut',
    'Beqaa',
    'Mount Lebanon',
    'Nabatieh',
    'North',
    'South',
  ];

  late String selectedGov;

  String _cityName = '';
  String _population = '';
  String _dateOfCreation = '';
  String _status = '';
  String _councilmembers = '';
  String _governorate = '';

  @override
  void initState() {
    super.initState();
    selectedGov = governorates.first;
    _cityName = widget.cityName;
    fetchCityData();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update City Data'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update data for city: $_cityName',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Population: $_population',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Date of Creation: $_dateOfCreation',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Council members: $_councilmembers',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Governorate: $_governorate',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Election Status: $_status',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _cityNamecontroller,
                    decoration: InputDecoration(

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Styles.textColor),
                      hintStyle: TextStyle(color: Styles.textColor),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _populationcontroller,
                    decoration: InputDecoration(

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                      labelText: 'Population',
                      labelStyle: TextStyle(color: Styles.textColor),
                      hintStyle: TextStyle(color: Styles.textColor),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
        
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _councilmemberscontroller,

                    decoration: InputDecoration(

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black12,
                          width: 5.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                      labelText: 'Council Members',
                      labelStyle: TextStyle(color: Styles.textColor),
                      hintStyle: TextStyle(color: Styles.textColor),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
        
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedGov,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGov = newValue!;
                      });
                    },
                    items: governorates.map((governorate) {
                      return DropdownMenuItem<String>(
                        value: governorate,
                        child: Text(governorate),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Styles.primaryColor),
                      ),
                      filled: true,
                      fillColor: Styles.bgcolor,
                      labelText: 'Governorate',
                      labelStyle: TextStyle(color: Styles.textColor),
                      hintStyle: TextStyle(color: Styles.textColor),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await updateCityInfo();
                      },
                      // Changed here
                      child: Text(
                        'Update City Info',
                        style: TextStyle(color: Styles.HomeTitle),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchCityData() async {
    try {
      QuerySnapshot citySnapshot = await FirebaseFirestore.instance.collection('Cities').get();
      for (DocumentSnapshot cityDoc in citySnapshot.docs) {
        if (cityDoc['name'] == _cityName) {
          setState(() {
            _population = cityDoc['population'];
            _dateOfCreation = cityDoc['dateofcreation'];
            _councilmembers = cityDoc['Council members'] != null ? cityDoc['Council members'].toString() : '';
            _governorate = cityDoc['Governorate'] != null ? cityDoc['Governorate'] : '';
            _status = cityDoc['status'] != null ? cityDoc['status'].toString() : '';
            selectedGov = _governorate;
          });

          _cityNamecontroller.text = _cityName;
          _populationcontroller.text = _population;
          _councilmemberscontroller.text = _councilmembers;
          _governoratecontroller.text = _governorate;

          return;
        }
      }

      print('City not found.');
    } catch (error) {
      print('Error fetching city data: $error');
    }
  }


  Future<void> updateCityInfo() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      String updatedCityName = _cityNamecontroller.text.trim();
      String updatedPopulation = _populationcontroller.text.trim();
      int? updatedCouncilMembers;

      try {
        updatedCouncilMembers = int.parse(_councilmemberscontroller.text.trim());
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Council members must be an integer')));
        return;
      }

      Map<String, dynamic> updatedData = {
        'name': updatedCityName,
        'population': updatedPopulation,
        'Council members': updatedCouncilMembers,
        'Governorate': selectedGov,
      };

      // Update city information in the "Cities" collection
      await FirebaseFirestore.instance.collection('Cities').doc(widget.cityDocument.id).update(updatedData);
      fetchCityData();
      // Update corresponding data in the "election" collection
      await updateElectionData(_cityName,updatedCityName, selectedGov, updatedPopulation);
      await updateCandidatesVillage(_cityName, updatedCityName);
      await updateVotersVillage(_cityName, updatedCityName);
      await updateVotesListsVillage(_cityName, updatedCityName);
      await updateVotesVillage(_cityName, updatedCityName);
      setState(() {
        _cityName = updatedCityName;
        _population = updatedPopulation;
        _councilmembers = updatedCouncilMembers.toString();
        _governorate = selectedGov;
      });

      Navigator.of(context).pop();

      fetchCityData();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('City information updated successfully')));
    } catch (error) {
      Navigator.of(context).pop();
      print('Error updating city information: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update city information: $error')));
    }
  }

  Future<void> updateElectionData(String oldCityName, String newCityName, String governorate, String population) async {
    try {
      // Fetch election documents where city name matches the old city name
      QuerySnapshot<Map<String, dynamic>> electionDocs = await FirebaseFirestore.instance
          .collection('election')
          .where('name', isEqualTo: oldCityName)
          .get();

      // Update each document
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in electionDocs.docs) {
        // Update relevant fields including the city name
        await doc.reference.update({
          'name': newCityName,
          'governorate': governorate,
          'population': population,
        });
      }
    } catch (error) {
      print('Error updating election data: $error');
    }
  }


  Future<void> updateCandidatesVillage(String oldCityName, String newCityName) async {
    try {
      // Fetch candidate documents where city name matches the old city name
      QuerySnapshot<Map<String, dynamic>> candidateDocs = await FirebaseFirestore.instance
          .collection('candidates')
          .where('Candidate Village', isEqualTo: oldCityName)
          .get();

      // Update each document
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in candidateDocs.docs) {
        // Update the village field
        await doc.reference.update({
          'Candidate Village': newCityName,
        });
      }
    } catch (error) {
      print('Error updating candidates village: $error');
    }
  }

  Future<void> updateVotersVillage(String oldCityName, String newCityName) async {
    try {
      // Fetch voter documents where city name matches the old city name
      QuerySnapshot<Map<String, dynamic>> voterDocs = await FirebaseFirestore.instance
          .collection('Voters_data')
          .where('Voter Village', isEqualTo: oldCityName)
          .get();

      // Update each document
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in voterDocs.docs) {
        // Update the village field
        await doc.reference.update({
          'Voter Village': newCityName,
        });
      }
    } catch (error) {
      print('Error updating voters village: $error');
    }
  }


  Future<void> updateVotesVillage(String oldCityName, String newCityName) async {
    try {
      // Fetch voter documents where city name matches the old city name
      QuerySnapshot<Map<String, dynamic>> voterDocs = await FirebaseFirestore.instance
          .collection('votes_lists')
          .where('City', isEqualTo: oldCityName)
          .get();

      // Update each document
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in voterDocs.docs) {
        // Update the village field
        await doc.reference.update({
          'City': newCityName,
        });
      }
    } catch (error) {
      print('Error updating voters village: $error');
    }
  }

  Future<void> updateVotesListsVillage(String oldCityName, String newCityName) async {
    try {
      // Fetch voter documents where city name matches the old city name
      QuerySnapshot<Map<String, dynamic>> voterDocs = await FirebaseFirestore.instance
          .collection('votes')
          .where('City', isEqualTo: oldCityName)
          .get();

      // Update each document
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in voterDocs.docs) {
        // Update the village field
        await doc.reference.update({
          'City': newCityName,
        });
      }
    } catch (error) {
      print('Error updating voters village: $error');
    }
  }


}
