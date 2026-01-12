import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents Key Performance Indicator targets for a Preacher
/// This model stores the target values set by MUIP Officials
class KPITarget {
  final String? id; // Firestore document ID
  final String preacherId; // Reference to Preacher document ID
  
  // KPI Metrics (Target Values)
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
    required this.monthlySessionTarget,
    required this.totalAttendanceTarget,
    required this.newConvertsTarget,
    required this.baptismsTarget,
    required this.communityProjectsTarget,
    required this.charityEventsTarget,
    required this.youthProgramAttendanceTarget,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'preacher_id': preacherId,
      'monthly_session_target': monthlySessionTarget,
      'total_attendance_target': totalAttendanceTarget,
      'new_converts_target': newConvertsTarget,
      'baptisms_target': baptismsTarget,
      'community_projects_target': communityProjectsTarget,
      'charity_events_target': charityEventsTarget,
      'youth_program_attendance_target': youthProgramAttendanceTarget,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
  
  // Create from Firestore document
  factory KPITarget.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KPITarget(
      id: doc.id,
      preacherId: data['preacher_id'] ?? '',
      monthlySessionTarget: data['monthly_session_target'] ?? 0,
      totalAttendanceTarget: data['total_attendance_target'] ?? 0,
      newConvertsTarget: data['new_converts_target'] ?? 0,
      baptismsTarget: data['baptisms_target'] ?? 0,
      communityProjectsTarget: data['community_projects_target'] ?? 0,
      charityEventsTarget: data['charity_events_target'] ?? 0,
      youthProgramAttendanceTarget: data['youth_program_attendance_target'] ?? 0,
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
    );
  }
  
  // Create a copy with modified fields
  KPITarget copyWith({
    String? id,
    String? preacherId,
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
