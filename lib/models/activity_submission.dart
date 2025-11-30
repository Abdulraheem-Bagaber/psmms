import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitySubmission {
  final String id;
  final String activityId;
  final String preacherId;
  final String preacherName;
  final double latitude;
  final double longitude;
  final List<String> photoUrls;
  final DateTime submittedAt;
  final String status; // "Pending", "Approved", "Rejected"
  final String? reviewNotes;
  final DateTime? reviewedAt;

  ActivitySubmission({
    required this.id,
    required this.activityId,
    required this.preacherId,
    required this.preacherName,
    required this.latitude,
    required this.longitude,
    required this.photoUrls,
    required this.submittedAt,
    required this.status,
    this.reviewNotes,
    this.reviewedAt,
  });

  factory ActivitySubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivitySubmission(
      id: doc.id,
      activityId: data['activityId'] ?? '',
      preacherId: data['preacherId'] ?? '',
      preacherName: data['preacherName'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      reviewNotes: data['reviewNotes'],
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'activityId': activityId,
      'preacherId': preacherId,
      'preacherName': preacherName,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrls': photoUrls,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'status': status,
      'reviewNotes': reviewNotes,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }
}
