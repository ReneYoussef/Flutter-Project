import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUtils {
  static Future<bool> checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(user.uid)
          .get();
      if (userSnapshot.exists) {
       String role = userSnapshot.get('role');
    print('[[[[[[[[[[[[[[$role]]]]]]]]]]]]]]');
        return role == 'admin';
      }
    }
    return false;
  }

  static Future<bool> checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot VoterSnapshot = await FirebaseFirestore.instance
          .collection('Voters_data')
          .doc(user.uid)
          .get();
      DocumentSnapshot CandidateSnapshot = await FirebaseFirestore.instance
          .collection('candidates')
          .doc(user.uid)
          .get();
      if (VoterSnapshot.exists) {
        String role = VoterSnapshot.get('role');
        print('[[[[[[[[[[[[[[$role]]]]]]]]]]]]]]');
        return role == 'voter';
      }
      else if (CandidateSnapshot.exists) {
        String role = CandidateSnapshot.get('role');
        print('[[[[[[[[[[[[[[$role]]]]]]]]]]]]]]');
        return role == 'candidate';
      }
    }
    return false;
  }
}
