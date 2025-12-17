import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? role; // Mother, Father, etc.
  final String? currentBabyId; // Link to the active baby profile
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.role,
    this.currentBabyId,
    this.createdAt,
  });

  // Convert to Map for Firestor
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'currentBabyId': currentBabyId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      role: map['role'],
      currentBabyId: map['currentBabyId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
