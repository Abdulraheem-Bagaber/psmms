import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'officer', 'preacher', 'admin'
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.additionalData,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'preacher',
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'additionalData': additionalData,
    };
  }

  // Helper methods to check user role
  bool get isOfficer => role.toLowerCase() == 'officer';
  bool get isPreacher => role.toLowerCase() == 'preacher';
  bool get isAdmin => 
      role.toLowerCase() == 'admin' || 
      role.toLowerCase() == 'muip_admin' ||
      role.toLowerCase() == 'muip admin';

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
