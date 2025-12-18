import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogModel {
  final String id;
  final String type; // 'feed', 'sleep', 'diaper', 'growth'
  final String? subType; // e.g. 'nursing', 'bottle', 'wet', 'dirty'
  final DateTime timestamp;
  final Map<String, dynamic> details;

  ActivityLogModel({
    required this.id,
    required this.type,
    this.subType,
    required this.timestamp,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'subType': subType,
      'timestamp': Timestamp.fromDate(timestamp),
      'details': details,
    };
  }

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      subType: map['subType'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
    );
  }
}
