// Service: FirestoreService
// Handles all Firestore database operations for the MUIP PSM application

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/User.dart';
import '../models/KPITarget.dart';
import '../models/KPIProgress.dart';
import '../models/PreacherProfile.dart';
import '../models/SavedReport.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection names
  static const String preachersCollection = 'preachers';
  static const String kpiTargetsCollection = 'kpi_targets';
  static const String kpiProgressCollection = 'kpi_progress';
  static const String preacherProfilesCollection = 'preacher_profiles';
  static const String savedReportsCollection = 'saved_reports';

  // ==================== PREACHER OPERATIONS ====================

  /// Add a new preacher to Firestore
  Future<String> addPreacher(Preacher preacher) async {
    try {
      final docRef = await _db.collection(preachersCollection).add(preacher.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add preacher: $e');
    }
  }

  /// Get all preachers as a stream
  Stream<List<Preacher>> getPreachers() {
    return _db
        .collection(preachersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Preacher.fromFirestore(doc))
            .toList());
  }

  /// Get a single preacher by ID
  Future<Preacher?> getPreacherById(String id) async {
    try {
      final doc = await _db.collection(preachersCollection).doc(id).get();
      if (doc.exists) {
        return Preacher.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get preacher: $e');
    }
  }

  /// Update an existing preacher
  Future<void> updatePreacher(String id, Preacher preacher) async {
    try {
      await _db.collection(preachersCollection).doc(id).update({
        'name': preacher.name,
        'email': preacher.email,
        'phone': preacher.phone,
        'avatar_url': preacher.avatarUrl,
        'status': preacher.status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update preacher: $e');
    }
  }

  /// Delete a preacher
  Future<void> deletePreacher(String id) async {
    try {
      await _db.collection(preachersCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete preacher: $e');
    }
  }

  /// Get preachers by status
  Stream<List<Preacher>> getPreachersByStatus(String status) {
    return _db
        .collection(preachersCollection)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Preacher.fromFirestore(doc))
            .toList());
  }

  // ==================== KPI TARGET OPERATIONS ====================

  /// Add a new KPI target
  Future<String> addKPITarget(KPI kpi) async {
    try {
      final docRef = await _db.collection(kpiTargetsCollection).add(kpi.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add KPI target: $e');
    }
  }

  /// Get all KPI targets for a specific preacher
  Stream<List<KPI>> getKPITargetsByPreacher(String preacherId) {
    return _db
        .collection(kpiTargetsCollection)
        .where('preacher_id', isEqualTo: preacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KPI.fromFirestore(doc))
            .toList());
  }

  /// Get a single KPI target by ID
  Future<KPI?> getKPITargetById(String id) async {
    try {
      final doc = await _db.collection(kpiTargetsCollection).doc(id).get();
      if (doc.exists) {
        return KPI.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get KPI target: $e');
    }
  }

  /// Update a KPI target
  Future<void> updateKPITarget(String id, KPI kpi) async {
    try {
      await _db.collection(kpiTargetsCollection).doc(id).update({
        'monthly_session_target': kpi.monthlySessionTarget,
        'total_attendance_target': kpi.totalAttendanceTarget,
        'new_converts_target': kpi.newConvertsTarget,
        'baptisms_target': kpi.baptismsTarget,
        'community_projects_target': kpi.communityProjectsTarget,
        'charity_events_target': kpi.charityEventsTarget,
        'youth_program_attendance_target': kpi.youthProgramAttendanceTarget,
        'start_date': Timestamp.fromDate(kpi.startDate),
        'end_date': Timestamp.fromDate(kpi.endDate),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update KPI target: $e');
    }
  }

  /// Delete a KPI target
  Future<void> deleteKPITarget(String id) async {
    try {
      await _db.collection(kpiTargetsCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete KPI target: $e');
    }
  }

  /// Get active KPI targets for a preacher (within current date range)
  Stream<List<KPI>> getActiveKPITargets(String preacherId) {
    final now = Timestamp.now();
    return _db
        .collection(kpiTargetsCollection)
        .where('preacher_id', isEqualTo: preacherId)
        .where('start_date', isLessThanOrEqualTo: now)
        .where('end_date', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KPI.fromFirestore(doc))
            .toList());
  }

  // ==================== KPI PROGRESS OPERATIONS ====================

  /// Add or update KPI progress
  Future<String> setKPIProgress(KPIProgress progress) async {
    try {
      if (progress.id != null) {
        // Update existing progress
        await _db.collection(kpiProgressCollection).doc(progress.id).update(progress.toFirestore());
        return progress.id!;
      } else {
        // Add new progress
        final docRef = await _db.collection(kpiProgressCollection).add(progress.toFirestore());
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Failed to set KPI progress: $e');
    }
  }

  /// Get KPI progress for a specific KPI
  Future<KPIProgress?> getKPIProgress(String kpiId, String preacherId) async {
    try {
      final querySnapshot = await _db
          .collection(kpiProgressCollection)
          .where('kpi_id', isEqualTo: kpiId)
          .where('preacher_id', isEqualTo: preacherId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return KPIProgress.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get KPI progress: $e');
    }
  }

  /// Get all KPI progress for a preacher
  Stream<List<KPIProgress>> getKPIProgressByPreacher(String preacherId) {
    return _db
        .collection(kpiProgressCollection)
        .where('preacher_id', isEqualTo: preacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KPIProgress.fromFirestore(doc))
            .toList());
  }

  /// Update specific achievement in KPI progress
  Future<void> updateKPIAchievement(String progressId, Map<String, dynamic> updates) async {
    try {
      updates['last_updated'] = FieldValue.serverTimestamp();
      await _db.collection(kpiProgressCollection).doc(progressId).update(updates);
    } catch (e) {
      throw Exception('Failed to update KPI achievement: $e');
    }
  }

  /// Delete KPI progress
  Future<void> deleteKPIProgress(String id) async {
    try {
      await _db.collection(kpiProgressCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete KPI progress: $e');
    }
  }

  // ==================== COMBINED OPERATIONS ====================

  /// Get KPI with Progress for a preacher (joined data)
  Future<Map<String, dynamic>> getKPIWithProgress(String preacherId) async {
    try {
      final kpiTargets = await getKPITargetsByPreacher(preacherId).first;
      final kpiProgress = await getKPIProgressByPreacher(preacherId).first;

      return {
        'targets': kpiTargets,
        'progress': kpiProgress,
      };
    } catch (e) {
      throw Exception('Failed to get KPI with progress: $e');
    }
  }

  /// Initialize KPI progress when a new KPI target is created
  Future<void> initializeKPIProgress(String kpiId, String preacherId) async {
    final progress = KPIProgress(
      kpiId: kpiId,
      preacherId: preacherId,
    );
    await setKPIProgress(progress);
  }

  // ==================== PREACHER PROFILE OPERATIONS ====================

  /// Add a new preacher profile
  Future<String> addPreacherProfile(PreacherProfile profile) async {
    try {
      final docRef = await _db.collection(preacherProfilesCollection).add(profile.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add preacher profile: $e');
    }
  }

  /// Get preacher profile by user ID
  Future<PreacherProfile?> getPreacherProfileByUserId(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(preacherProfilesCollection)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PreacherProfile.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get preacher profile: $e');
    }
  }

  /// Update preacher profile
  Future<void> updatePreacherProfile(String id, PreacherProfile profile) async {
    try {
      await _db.collection(preacherProfilesCollection).doc(id).update({
        'full_name': profile.fullName,
        'id_number': profile.idNumber,
        'phone_number': profile.phoneNumber,
        'address': profile.address,
        'qualifications': profile.qualifications ?? [],
        'skills': profile.skills ?? [],
        'profile_status': profile.profileStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update preacher profile: $e');
    }
  }

  /// Delete preacher profile
  Future<void> deletePreacherProfile(String id) async {
    try {
      await _db.collection(preacherProfilesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete preacher profile: $e');
    }
  }

  // ==================== SAVED REPORT OPERATIONS ====================

  /// Save a report
  Future<String> saveReport(SavedReport report) async {
    try {
      final docRef = await _db.collection(savedReportsCollection).add(report.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }

  /// Get all reports
  Stream<List<SavedReport>> getReports() {
    return _db
        .collection(savedReportsCollection)
        .orderBy('generated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedReport.fromFirestore(doc))
            .toList());
  }

  /// Get reports by type
  Stream<List<SavedReport>> getReportsByType(String type) {
    return _db
        .collection(savedReportsCollection)
        .where('report_type', isEqualTo: type)
        .orderBy('generated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedReport.fromFirestore(doc))
            .toList());
  }

  /// Get reports by user
  Stream<List<SavedReport>> getReportsByUser(String userId) {
    return _db
        .collection(savedReportsCollection)
        .where('generated_by', isEqualTo: userId)
        .orderBy('generated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedReport.fromFirestore(doc))
            .toList());
  }

  /// Delete a report
  Future<void> deleteReport(String id) async {
    try {
      await _db.collection(savedReportsCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}
