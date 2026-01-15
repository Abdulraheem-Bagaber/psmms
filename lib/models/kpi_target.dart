import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents Key Performance Indicator targets for a Preacher
/// This model stores the target values set by MUIP Officials
class KPITarget {
  final String? id; // Firestore document ID
  final String preacherId; // Reference to Preacher document ID

  // KPI Metrics (Target Values)
  final int targetTarbiah;
  final int targetDakwah;
  final int targetAqidah;
  final int targetIrtiqak;
  final int targetKhidmat;
  final double targetDonations;
  final int targetActivities;
  
  // Additional fields for backward compatibility
  final int monthlySessionTarget;
  final int totalAttendanceTarget;
  final int newConvertsTarget;
  final int baptismsTarget;
  final int communityProjectsTarget;
  final int charityEventsTarget;
  final int youthProgramAttendanceTarget;

  // Performance Period
  final DateTime startDate;
  final DateTime endDate;

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;

  KPITarget({
    this.id,
    required this.preacherId,
    required this.targetTarbiah,
    required this.targetDakwah,
    required this.targetAqidah,
    required this.targetIrtiqak,
    required this.targetKhidmat,
    required this.targetDonations,
    required this.targetActivities,
    this.monthlySessionTarget = 0,
    this.totalAttendanceTarget = 0,
    this.newConvertsTarget = 0,
    this.baptismsTarget = 0,
    this.communityProjectsTarget = 0,
    this.charityEventsTarget = 0,
    this.youthProgramAttendanceTarget = 0,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map format
  Map<String, dynamic> toMap() {
    return {
      'preacher_id': preacherId,
      'target_tarbiah': targetTarbiah,
      'target_dakwah': targetDakwah,
      'target_aqidah': targetAqidah,
      'target_irtiqak': targetIrtiqak,
      'target_khidmat': targetKhidmat,
      'target_donations': targetDonations,
      'target_activities': targetActivities,
      'monthly_session_target': monthlySessionTarget,
      'total_attendance_target': totalAttendanceTarget,
      'new_converts_target': newConvertsTarget,
      'baptisms_target': baptismsTarget,
      'community_projects_target': communityProjectsTarget,
      'charity_events_target': charityEventsTarget,
      'youth_program_attendance_target': youthProgramAttendanceTarget,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert to Firestore format (for backward compatibility)
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // Create from Map
  factory KPITarget.fromMap(Map<String, dynamic> map, {String? docId}) {
    return KPITarget(
      id: docId ?? map['id'],
      preacherId: map['preacher_id'] ?? '',
      targetTarbiah: map['target_tarbiah'] ?? 0,
      targetDakwah: map['target_dakwah'] ?? 0,
      targetAqidah: map['target_aqidah'] ?? 0,
      targetIrtiqak: map['target_irtiqak'] ?? 0,
      targetKhidmat: map['target_khidmat'] ?? 0,
      targetDonations: (map['target_donations'] ?? 0.0).toDouble(),
      targetActivities: map['target_activities'] ?? 0,
      monthlySessionTarget: map['monthly_session_target'] ?? 0,
      totalAttendanceTarget: map['total_attendance_target'] ?? 0,
      newConvertsTarget: map['new_converts_target'] ?? 0,
      baptismsTarget: map['baptisms_target'] ?? 0,
      communityProjectsTarget: map['community_projects_target'] ?? 0,
      charityEventsTarget: map['charity_events_target'] ?? 0,
      youthProgramAttendanceTarget: map['youth_program_attendance_target'] ?? 0,
      startDate: (map['start_date'] as Timestamp).toDate(),
      endDate: (map['end_date'] as Timestamp).toDate(),
      createdAt:
          map['created_at'] != null
              ? (map['created_at'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          map['updated_at'] != null
              ? (map['updated_at'] as Timestamp).toDate()
              : null,
    );
  }

  // Create from Firestore document (for backward compatibility)
  factory KPITarget.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KPITarget.fromMap(data, docId: doc.id);
  }

  // Create a copy with modified fields
  KPITarget copyWith({
    String? id,
    String? preacherId,
    int? targetTarbiah,
    int? targetDakwah,
    int? targetAqidah,
    int? targetIrtiqak,
    int? targetKhidmat,
    double? targetDonations,
    int? targetActivities,
    int? monthlySessionTarget,
    int? totalAttendanceTarget,
    int? newConvertsTarget,
    int? baptismsTarget,
    int? communityProjectsTarget,
    int? charityEventsTarget,
    int? youthProgramAttendanceTarget,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KPITarget(
      id: id ?? this.id,
      preacherId: preacherId ?? this.preacherId,
      targetTarbiah: targetTarbiah ?? this.targetTarbiah,
      targetDakwah: targetDakwah ?? this.targetDakwah,
      targetAqidah: targetAqidah ?? this.targetAqidah,
      targetIrtiqak: targetIrtiqak ?? this.targetIrtiqak,
      targetKhidmat: targetKhidmat ?? this.targetKhidmat,
      targetDonations: targetDonations ?? this.targetDonations,
      targetActivities: targetActivities ?? this.targetActivities,
      monthlySessionTarget: monthlySessionTarget ?? this.monthlySessionTarget,
      totalAttendanceTarget: totalAttendanceTarget ?? this.totalAttendanceTarget,
      newConvertsTarget: newConvertsTarget ?? this.newConvertsTarget,
      baptismsTarget: baptismsTarget ?? this.baptismsTarget,
      communityProjectsTarget: communityProjectsTarget ?? this.communityProjectsTarget,
      charityEventsTarget: charityEventsTarget ?? this.charityEventsTarget,
      youthProgramAttendanceTarget: youthProgramAttendanceTarget ?? this.youthProgramAttendanceTarget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KPITarget(id: $id, preacherId: $preacherId, period: $startDate - $endDate)';
  }
}
