import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastActive;
  final int totalSessions;
  final double averageSecurityScore;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastActive,
    this.totalSessions = 0,
    this.averageSecurityScore = 0.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      totalSessions: data['totalSessions'] ?? 0,
      averageSecurityScore: (data['averageSecurityScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'totalSessions': totalSessions,
      'averageSecurityScore': averageSecurityScore,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    DateTime? lastActive,
    int? totalSessions,
    double? averageSecurityScore,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
      totalSessions: totalSessions ?? this.totalSessions,
      averageSecurityScore: averageSecurityScore ?? this.averageSecurityScore,
    );
  }
}
