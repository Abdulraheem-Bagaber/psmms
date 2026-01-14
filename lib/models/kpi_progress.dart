import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the actual progress/achievement for a Preacher's KPI
/// This model stores the current achievement values
/// Progress is updated from Activity Management module
class KPIProgress {
  final String? id; // Firestore document ID
  final String preacherId; // Reference to Preacher document ID

  // Current Achievement Values
  final int achievedTarbiah;
  final int achievedDakwah;
  final int achievedAqidah;
  final int achievedIrtiqak;
  final int achievedKhidmat;
  final double achievedDonations;
  final int achievedActivities;

  // Performance Tracking
  final double overallPercentage;
  final String performanceStatus; // 'excellent', 'good', 'warning', 'critical', 'new'
  final int performancePoints;
  final int ranking; // Position in leaderboard (1 = top)

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  KPIProgress({
    this.id,
    required this.preacherId,
    this.achievedTarbiah = 0,
    this.achievedDakwah = 0,
    this.achievedAqidah = 0,
    this.achievedIrtiqak = 0,
    this.achievedKhidmat = 0,
    this.achievedDonations = 0.0,
    this.achievedActivities = 0,
    this.overallPercentage = 0.0,
    this.performanceStatus = 'new',
    this.performancePoints = 0,
    this.ranking = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Calculate progress percentage for a specific metric
  double calculateProgress(int achieved, int target) {
    if (target == 0) return 0.0;
    return (achieved / target * 100).clamp(0.0, 100.0);
  }

  // Get status color based on progress
  String getStatusColor(double progressPercentage) {
    if (progressPercentage >= 75) return 'green';
    if (progressPercentage >= 50) return 'yellow';
    return 'red';
  }

  // Convert to Map format
  Map<String, dynamic> toMap() {
    return {
      'preacher_id': preacherId,
      'achieved_tarbiah': achievedTarbiah,
      'achieved_dakwah': achievedDakwah,
      'achieved_aqidah': achievedAqidah,
      'achieved_irtiqak': achievedIrtiqak,
      'achieved_khidmat': achievedKhidmat,
      'achieved_donations': achievedDonations,
      'achieved_activities': achievedActivities,
      'overall_percentage': overallPercentage,
      'performance_status': performanceStatus,
      'performance_points': performancePoints,
      'ranking': ranking,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert to Firestore format (for backward compatibility)
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // Create from Map
  factory KPIProgress.fromMap(Map<String, dynamic> map, {String? docId}) {
    return KPIProgress(
      id: docId ?? map['id'],
      preacherId: map['preacher_id'] ?? '',
      achievedTarbiah: map['achieved_tarbiah'] ?? 0,
      achievedDakwah: map['achieved_dakwah'] ?? 0,
      achievedAqidah: map['achieved_aqidah'] ?? 0,
      achievedIrtiqak: map['achieved_irtiqak'] ?? 0,
      achievedKhidmat: map['achieved_khidmat'] ?? 0,
      achievedDonations: (map['achieved_donations'] ?? 0.0).toDouble(),
      achievedActivities: map['achieved_activities'] ?? 0,
      overallPercentage: (map['overall_percentage'] ?? 0.0).toDouble(),
      performanceStatus: map['performance_status'] ?? 'new',
      performancePoints: map['performance_points'] ?? 0,
      ranking: map['ranking'] ?? 0,
      createdAt:
          map['created_at'] != null
              ? (map['created_at'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          map['updated_at'] != null
              ? (map['updated_at'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // Create from Firestore document (for backward compatibility)
  factory KPIProgress.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KPIProgress.fromMap(data, docId: doc.id);
  }

  // Create a copy with modified fields
  KPIProgress copyWith({
    String? id,
    String? preacherId,
    int? achievedTarbiah,
    int? achievedDakwah,
    int? achievedAqidah,
    int? achievedIrtiqak,
    int? achievedKhidmat,
    double? achievedDonations,
    int? achievedActivities,
    double? overallPercentage,
    String? performanceStatus,
    int? performancePoints,
    int? ranking,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KPIProgress(
      id: id ?? this.id,
      preacherId: preacherId ?? this.preacherId,
      achievedTarbiah: achievedTarbiah ?? this.achievedTarbiah,
      achievedDakwah: achievedDakwah ?? this.achievedDakwah,
      achievedAqidah: achievedAqidah ?? this.achievedAqidah,
      achievedIrtiqak: achievedIrtiqak ?? this.achievedIrtiqak,
      achievedKhidmat: achievedKhidmat ?? this.achievedKhidmat,
      achievedDonations: achievedDonations ?? this.achievedDonations,
      achievedActivities: achievedActivities ?? this.achievedActivities,
      overallPercentage: overallPercentage ?? this.overallPercentage,
      performanceStatus: performanceStatus ?? this.performanceStatus,
      performancePoints: performancePoints ?? this.performancePoints,
      ranking: ranking ?? this.ranking,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KPIProgress(id: $id, preacherId: $preacherId, tarbiah: $achievedTarbiah, dakwah: $achievedDakwah)';
  }
}
