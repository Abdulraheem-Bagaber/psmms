// Domain Model: PreacherProfile
// Component Name for SDD: PreacherProfile
// Package: com.muip.psm.domain

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents detailed profile information for a Preacher
/// Extended information beyond basic user credentials
class PreacherProfile {
  final String? id; // Document ID
  final String userId; // Links to User/Preacher
  final String fullName;
  final String idNumber; // Identity Card number
  final String phoneNumber;
  final String? address;
  final List<String>? qualifications; // Academic or religious certifications
  final List<String>? skills; // Specializations (e.g., "Youth Counseling")
  final String profileStatus; // 'Active', 'Pending'
  
  PreacherProfile({
    this.id,
    required this.userId,
    required this.fullName,
    required this.idNumber,
    required this.phoneNumber,
    this.address,
    this.qualifications,
    this.skills,
    this.profileStatus = 'Active',
  });
  
  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'id_number': idNumber,
      'phone_number': phoneNumber,
      'address': address,
      'qualifications': qualifications ?? [],
      'skills': skills ?? [],
      'profile_status': profileStatus,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
  
  // Create from Firestore document
  factory PreacherProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PreacherProfile(
      id: doc.id,
      userId: data['user_id'] ?? '',
      fullName: data['full_name'] ?? '',
      idNumber: data['id_number'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      address: data['address'],
      qualifications: data['qualifications'] != null 
          ? List<String>.from(data['qualifications']) 
          : null,
      skills: data['skills'] != null 
          ? List<String>.from(data['skills']) 
          : null,
      profileStatus: data['profile_status'] ?? 'Active',
    );
  }
  
  // Create from Map
  factory PreacherProfile.fromMap(Map<String, dynamic> map) {
    return PreacherProfile(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      fullName: map['full_name'] ?? '',
      idNumber: map['id_number'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      address: map['address'],
      qualifications: map['qualifications'] != null 
          ? List<String>.from(map['qualifications']) 
          : null,
      skills: map['skills'] != null 
          ? List<String>.from(map['skills']) 
          : null,
      profileStatus: map['profile_status'] ?? 'Active',
    );
  }
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'id_number': idNumber,
      'phone_number': phoneNumber,
      'address': address,
      'qualifications': qualifications,
      'skills': skills,
      'profile_status': profileStatus,
    };
  }
  
  // Copy with
  PreacherProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? idNumber,
    String? phoneNumber,
    String? address,
    List<String>? qualifications,
    List<String>? skills,
    String? profileStatus,
  }) {
    return PreacherProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      idNumber: idNumber ?? this.idNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      qualifications: qualifications ?? this.qualifications,
      skills: skills ?? this.skills,
      profileStatus: profileStatus ?? this.profileStatus,
    );
  }
  
  @override
  String toString() {
    return 'PreacherProfile(id: $id, fullName: $fullName, status: $profileStatus)';
  }
}
