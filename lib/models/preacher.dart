import 'package:cloud_firestore/cloud_firestore.dart';

class Preacher {
  final String id;
  final String preacherId;
  final String fullName;
  final String? email;
  final String? phone;
  final String region;
  final List<String> specialization;
  final List<String> skills;
  final String? bio;
  final String status; // Active, Suspended
  final double rating;
  final int completedActivities;
  final int approvedActivities;
  final int rejectedActivities;
  final double paymentsTotal;
  final DateTime? lastPaymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Preacher({
    required this.id,
    required this.preacherId,
    required this.fullName,
    this.email,
    this.phone,
    required this.region,
    required this.specialization,
    required this.skills,
    this.bio,
    required this.status,
    required this.rating,
    required this.completedActivities,
    required this.approvedActivities,
    required this.rejectedActivities,
    required this.paymentsTotal,
    required this.lastPaymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Preacher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    final tsCreated = data?['createdAt'] as Timestamp?;
    final tsUpdated = data?['updatedAt'] as Timestamp?;
    final tsLastPayment = data?['lastPaymentDate'] as Timestamp?;

    return Preacher(
      id: doc.id,
      preacherId:
          doc.id, // Always use document ID as preacher ID for consistency
      fullName: data?['fullName'] ?? '',
      email: data?['email'],
      phone: data?['phoneNumber'] ?? data?['phone'], // Handle both field names
      region: data?['region'] ?? 'Not Set',
      specialization:
          data?['specialization'] != null
              ? List<String>.from(data!['specialization'])
              : const [],
      skills:
          data?['skills'] != null
              ? List<String>.from(data!['skills'])
              : const [],
      bio: data?['bio'],
      status: data?['status'] ?? 'Active',
      rating: (data?['rating'] ?? 0.0).toDouble(),
      completedActivities: (data?['completedActivities'] ?? 0) as int,
      approvedActivities: (data?['approvedActivities'] ?? 0) as int,
      rejectedActivities: (data?['rejectedActivities'] ?? 0) as int,
      paymentsTotal: (data?['paymentsTotal'] ?? 0.0).toDouble(),
      lastPaymentDate: tsLastPayment?.toDate(),
      createdAt: tsCreated?.toDate() ?? DateTime.now(),
      updatedAt: tsUpdated?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'preacherId': preacherId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'region': region,
      'specialization': specialization,
      'skills': skills,
      'bio': bio,
      'status': status,
      'rating': rating,
      'completedActivities': completedActivities,
      'approvedActivities': approvedActivities,
      'rejectedActivities': rejectedActivities,
      'paymentsTotal': paymentsTotal,
      'lastPaymentDate':
          lastPaymentDate != null ? Timestamp.fromDate(lastPaymentDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Preacher copyWith({
    String? id,
    String? preacherId,
    String? fullName,
    String? email,
    String? phone,
    String? region,
    List<String>? specialization,
    List<String>? skills,
    String? bio,
    String? status,
    double? rating,
    int? completedActivities,
    int? approvedActivities,
    int? rejectedActivities,
    double? paymentsTotal,
    DateTime? lastPaymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Preacher(
      id: id ?? this.id,
      preacherId: preacherId ?? this.preacherId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      region: region ?? this.region,
      specialization: specialization ?? this.specialization,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      completedActivities: completedActivities ?? this.completedActivities,
      approvedActivities: approvedActivities ?? this.approvedActivities,
      rejectedActivities: rejectedActivities ?? this.rejectedActivities,
      paymentsTotal: paymentsTotal ?? this.paymentsTotal,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
