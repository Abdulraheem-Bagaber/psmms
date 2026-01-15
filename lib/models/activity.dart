import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String activityId;
  final String activityType;
  final String title;
  final String location;
  final String venue;
  final DateTime activityDate;
  final String startTime;
  final String endTime;
  final String topic;
  final String specialRequirements;
  final String? assignedPreacherId;
  final String? assignedPreacherName;
  final int? expectedAttendance; // Number of expected attendees
  final String
  status; // "Available", "Assigned", "Submitted", "Pending Payment", "Rejected"
  final String urgency; // "Normal", "Urgent"
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.activityId,
    required this.activityType,
    required this.title,
    required this.location,
    required this.venue,
    required this.activityDate,
    required this.startTime,
    required this.endTime,
    required this.topic,
    required this.specialRequirements,
    this.assignedPreacherId,
    this.assignedPreacherName,
    this.expectedAttendance,
    required this.status,
    required this.urgency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      activityId: data['activityId'] ?? '',
      activityType: data['activityType'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      venue: data['venue'] ?? '',
      activityDate: (data['activityDate'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      topic: data['topic'] ?? '',
      specialRequirements: data['specialRequirements'] ?? '',
      assignedPreacherId: data['assignedPreacherId'],
      assignedPreacherName: data['assignedPreacherName'],
      expectedAttendance: data['expectedAttendance'] as int?,
      status: data['status'] ?? 'Available',
      urgency: data['urgency'] ?? 'Normal',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'activityId': activityId,
      'activityType': activityType,
      'title': title,
      'location': location,
      'venue': venue,
      'activityDate': Timestamp.fromDate(activityDate),
      'startTime': startTime,
      'endTime': endTime,
      'topic': topic,
      'specialRequirements': specialRequirements,
      'assignedPreacherId': assignedPreacherId,
      'assignedPreacherName': assignedPreacherName,
      'expectedAttendance': expectedAttendance,
      'status': status,
      'urgency': urgency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Activity copyWith({
    String? id,
    String? activityId,
    String? activityType,
    String? title,
    String? location,
    String? venue,
    DateTime? activityDate,
    String? startTime,
    String? endTime,
    String? topic,
    String? specialRequirements,
    String? assignedPreacherId,
    String? assignedPreacherName,
    int? expectedAttendance,
    String? status,
    String? urgency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      location: location ?? this.location,
      venue: venue ?? this.venue,
      activityDate: activityDate ?? this.activityDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      topic: topic ?? this.topic,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      assignedPreacherId: assignedPreacherId ?? this.assignedPreacherId,
      assignedPreacherName: assignedPreacherName ?? this.assignedPreacherName,
      expectedAttendance: expectedAttendance ?? this.expectedAttendance,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
