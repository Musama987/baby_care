import 'package:cloud_firestore/cloud_firestore.dart';

class BabyModel {
  final String id;
  final String name;
  final DateTime dob;
  final String gender; // Boy, Girl, Optional
  final List<String> parentIds; // The users who have access to this profile
  final String? imageUrl; // Local path or URL
  final DateTime? createdAt;

  BabyModel({
    required this.id,
    required this.name,
    required this.dob,
    required this.gender,
    required this.parentIds,
    this.imageUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': Timestamp.fromDate(dob),
      'gender': gender,
      'parentIds': parentIds,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory BabyModel.fromMap(Map<String, dynamic> map) {
    return BabyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dob: (map['dob'] as Timestamp).toDate(),
      gender: map['gender'] ?? 'Optional',
      parentIds: List<String>.from(map['parentIds'] ?? []),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
