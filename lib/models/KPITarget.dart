// Domain Model: KPI
// Component Name for SDD: KPI
// Package: com.muip.psm.domain

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents Key Performance Indicator targets for a Preacher
/// This model stores the target values set by MUIP Officials
class KPI {
  final String? id; // Changed to String for Firestore document ID
  final String preacherId; // Changed to String to reference Preacher document ID
  
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
  
  KPI({
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
  
  // Convert KPI object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'preacher_id': preacherId,
      'monthly_session_target': monthlySessionTarget,
      'total_attendance_target': totalAttendanceTarget,
      'new_converts_target': newConvertsTarget,
      'baptisms_target': baptismsTarget,
      'community_projects_target': communityProjectsTarget,
      'charity_events_target': charityEventsTarget,
      'youth_program_attendance_target': youthProgramAttendanceTarget,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
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
  
  // Create KPI object from database Map
  factory KPI.fromMap(Map<String, dynamic> map) {
    return KPI(
      id: map['id']?.toString(),
      preacherId: map['preacher_id']?.toString() ?? '',
      monthlySessionTarget: map['monthly_session_target'] as int,
      totalAttendanceTarget: map['total_attendance_target'] as int,
      newConvertsTarget: map['new_converts_target'] as int,
      baptismsTarget: map['baptisms_target'] as int,
      communityProjectsTarget: map['community_projects_target'] as int,
      charityEventsTarget: map['charity_events_target'] as int,
      youthProgramAttendanceTarget: map['youth_program_attendance_target'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }
  
  // Create from Firestore document
  factory KPI.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KPI(
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
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null,
    );
  }
  
  // Create a copy of KPI with modified fields
  KPI copyWith({
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
    return KPI(
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
    return 'KPI(id: $id, preacherId: $preacherId, period: $startDate - $endDate)';
  }
}
