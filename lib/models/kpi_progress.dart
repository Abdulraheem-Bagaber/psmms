import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the actual progress/achievement for a Preacher's KPI
/// This model stores the current achievement values
/// Progress is updated from Activity Management module
class KPIProgress {
  final String? id; // Firestore document ID
  final String kpiId; // Reference to KPITarget document ID
  final String preacherId; // Reference to Preacher document ID

  // Current Achievement Values
  final int sessionsCompleted;
  final int totalAttendanceAchieved;
  final int newConvertsAchieved;
  final int baptismsAchieved;
  final int communityProjectsAchieved;
  final int charityEventsAchieved;
  final int youthProgramAttendanceAchieved;

  // Metadata
  final DateTime lastUpdated;

  KPIProgress({
    this.id,
    required this.kpiId,
    required this.preacherId,
    this.sessionsCompleted = 0,
    this.totalAttendanceAchieved = 0,
    this.newConvertsAchieved = 0,
    this.baptismsAchieved = 0,
    this.communityProjectsAchieved = 0,
    this.charityEventsAchieved = 0,
    this.youthProgramAttendanceAchieved = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

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

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'kpi_id': kpiId,
      'preacher_id': preacherId,
      'sessions_completed': sessionsCompleted,
      'total_attendance_achieved': totalAttendanceAchieved,
      'new_converts_achieved': newConvertsAchieved,
      'baptisms_achieved': baptismsAchieved,
      'community_projects_achieved': communityProjectsAchieved,
      'charity_events_achieved': charityEventsAchieved,
      'youth_program_attendance_achieved': youthProgramAttendanceAchieved,
      'last_updated': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory KPIProgress.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KPIProgress(
      id: doc.id,
      kpiId: data['kpi_id'] ?? '',
      preacherId: data['preacher_id'] ?? '',
      sessionsCompleted: data['sessions_completed'] ?? 0,
      totalAttendanceAchieved: data['total_attendance_achieved'] ?? 0,
      newConvertsAchieved: data['new_converts_achieved'] ?? 0,
      baptismsAchieved: data['baptisms_achieved'] ?? 0,
      communityProjectsAchieved: data['community_projects_achieved'] ?? 0,
      charityEventsAchieved: data['charity_events_achieved'] ?? 0,
      youthProgramAttendanceAchieved:
          data['youth_program_attendance_achieved'] ?? 0,
      lastUpdated:
          data['last_updated'] != null
              ? (data['last_updated'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // Create a copy with modified fields
  KPIProgress copyWith({
    String? id,
    String? kpiId,
    String? preacherId,
    int? sessionsCompleted,
    int? totalAttendanceAchieved,
    int? newConvertsAchieved,
    int? baptismsAchieved,
    int? communityProjectsAchieved,
    int? charityEventsAchieved,
    int? youthProgramAttendanceAchieved,
    DateTime? lastUpdated,
  }) {
    return KPIProgress(
      id: id ?? this.id,
      kpiId: kpiId ?? this.kpiId,
      preacherId: preacherId ?? this.preacherId,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      totalAttendanceAchieved:
          totalAttendanceAchieved ?? this.totalAttendanceAchieved,
      newConvertsAchieved: newConvertsAchieved ?? this.newConvertsAchieved,
      baptismsAchieved: baptismsAchieved ?? this.baptismsAchieved,
      communityProjectsAchieved:
          communityProjectsAchieved ?? this.communityProjectsAchieved,
      charityEventsAchieved:
          charityEventsAchieved ?? this.charityEventsAchieved,
      youthProgramAttendanceAchieved:
          youthProgramAttendanceAchieved ?? this.youthProgramAttendanceAchieved,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'KPIProgress(id: $id, kpiId: $kpiId, preacherId: $preacherId, sessions: $sessionsCompleted)';
  }
}
