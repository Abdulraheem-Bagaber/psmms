// Domain Model: Preacher
// Component Name for SDD: Preacher
// Package: com.muip.psm.domain

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Preacher in the MUIP system
/// This is a Domain Model used across multiple modules
class Preacher {
  final String? id; // Changed to String for Firestore document ID
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String status; // 'active', 'inactive', 'suspended'
  
  Preacher({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.status = 'active',
  });
  
  // Convert Preacher object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'status': status,
    };
  }
  
  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
  
  // Create Preacher object from database Map
  factory Preacher.fromMap(Map<String, dynamic> map) {
    return Preacher(
      id: map['id']?.toString(),
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      avatarUrl: map['avatar_url'] as String?,
      status: map['status'] as String? ?? 'active',
    );
  }
  
  // Create from Firestore document
  factory Preacher.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Preacher(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatar_url'],
      status: data['status'] ?? 'active',
    );
  }
  
  // Create a copy of Preacher with modified fields
  Preacher copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? status,
  }) {
    return Preacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
    );
  }
  
  @override
  String toString() {
    return 'Preacher(id: $id, name: $name, email: $email, status: $status)';
  }
}
