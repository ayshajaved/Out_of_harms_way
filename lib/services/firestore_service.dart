import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Save code session (placeholder)
  Future<void> saveCodeSession(String uid, Map<String, dynamic> sessionData) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history')
          .add({
        ...sessionData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update last active
      await _db.collection('users').doc(uid).update({
        'lastActive': FieldValue.serverTimestamp(),
        'totalSessions': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user code history (placeholder)
  Stream<QuerySnapshot> getUserCodeHistory(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
