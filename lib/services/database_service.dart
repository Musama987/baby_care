import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/baby_model.dart';
import '../models/activity_log_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- User Operations ---

  // Create or Update User
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error saving user: $e");
      rethrow;
    }
  }

  // Get User Stream
  Stream<UserModel> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!);
      } else {
        // Return a default/empty user or handle error accordingly
        return UserModel(uid: uid, email: '');
      }
    });
  }

  // Get User One-Time
  Future<UserModel?> getUser(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!);
      }
      return null;
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  // Update User Role
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': role});
    } catch (e) {
      print("Error updating role: $e");
      rethrow;
    }
  }

  // Update User's Current Baby
  Future<void> updateUserCurrentBaby(String uid, String babyId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'currentBabyId': babyId,
      });
    } catch (e) {
      print("Error updating current baby: $e");
      rethrow;
    }
  }

  // --- Baby Operations ---

  // Create Baby
  Future<void> createBaby(String uid, BabyModel baby) async {
    try {
      // 1. Save Baby to 'users/{uid}/babies' subcollection
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('babies')
          .doc(baby.id)
          .set(baby.toMap());

      // 2. Link Baby to User (Parent) - simply update current baby
      await updateUserCurrentBaby(uid, baby.id);
    } catch (e) {
      print("Error creating baby: $e");
      rethrow;
    }
  }

  // Get Baby Stream
  Stream<BabyModel?> getBabyStream(String uid, String babyId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('babies')
        .doc(babyId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return BabyModel.fromMap(snapshot.data()!);
          }
          return null;
        });
  }

  // Get All Babies for a User
  Stream<List<BabyModel>> getUserBabiesStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('babies')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BabyModel.fromMap(doc.data()))
              .toList();
        });
  }

  // --- Activity Log Operations ---

  // Add Activity Log
  Future<void> addActivityLog(
    String uid,
    String babyId,
    ActivityLogModel log,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('babies')
          .doc(babyId)
          .collection('logs')
          .doc(log.id)
          .set(log.toMap());
    } catch (e) {
      print("Error adding log: $e");
      rethrow;
    }
  }

  // Get Latest Activity Stream (e.g., Last Feed)
  Stream<ActivityLogModel?> getLatestActivityStream(
    String uid,
    String babyId,
    String type,
  ) {
    // Optimized: Fetch recent 20 logs ordered by time, then find first matching type in memory.
    // This avoids requiring a composite index (type + timestamp) for every activity type.
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('babies')
        .doc(babyId)
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['type'] == type) {
              return ActivityLogModel.fromMap(data);
            }
          }
          return null;
        });
  }

  // Get Logs for a specific day (for Daily Summary)
  Stream<List<ActivityLogModel>> getDailyLogsStream(
    String uid,
    String babyId,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('babies')
        .doc(babyId)
        .collection('logs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ActivityLogModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Get Growth Logs Stream (Ordered by Date Ascending for Charts)
  Stream<List<ActivityLogModel>> getGrowthLogsStream(
    String uid,
    String babyId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('babies')
        .doc(babyId)
        .collection('logs')
        .orderBy('timestamp', descending: false) // Oldest first
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ActivityLogModel.fromMap(doc.data()))
              .where((log) => log.type == 'growth')
              .toList();
        });
  }
}
