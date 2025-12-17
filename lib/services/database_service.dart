import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/baby_model.dart';

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
  Future<void> createBaby(BabyModel baby) async {
    try {
      // 1. Save Baby to 'babies' collection
      await _firestore.collection('babies').doc(baby.id).set(baby.toMap());

      // 2. Link Baby to User (Parent)
      // Assuming the baby model already has parentId set.
      if (baby.parentId != null) {
        await updateUserCurrentBaby(baby.parentId!, baby.id);
      }
    } catch (e) {
      print("Error creating baby: $e");
      rethrow;
    }
  }

  // Get Baby Stream
  Stream<BabyModel?> getBabyStream(String babyId) {
    return _firestore.collection('babies').doc(babyId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return BabyModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // Get All Babies for a User
  Stream<List<BabyModel>> getUserBabiesStream(String parentId) {
    return _firestore
        .collection('babies')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BabyModel.fromMap(doc.data()))
              .toList();
        });
  }
}
