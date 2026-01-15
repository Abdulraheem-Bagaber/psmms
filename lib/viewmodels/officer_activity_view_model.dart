import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/activity_submission.dart';

class OfficerActivityViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<Activity> get activities => _filteredActivities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  // Load all activities
  Future<void> loadActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot =
          await _db
              .collection('activities')
              .orderBy('createdAt', descending: true)
              .get();

      _activities =
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to load activities: $error';
      notifyListeners();
    }
  }

  // Search and filter
  void onSearchChanged(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  void onStatusFilterChanged(String status) {
    _statusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    List<Activity> result = List.from(_activities);

    // Apply status filter
    if (_statusFilter != 'All') {
      if (_statusFilter == 'Pending') {
        result = result.where((a) => a.status == 'Submitted').toList();
      } else if (_statusFilter == 'Approved') {
        result = result.where((a) => a.status == 'Approved').toList();
      } else if (_statusFilter == 'Rejected') {
        result = result.where((a) => a.status == 'Rejected').toList();
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result =
          result
              .where(
                (a) =>
                    a.title.toLowerCase().contains(query) ||
                    a.location.toLowerCase().contains(query) ||
                    (a.assignedPreacherName?.toLowerCase().contains(query) ??
                        false),
              )
              .toList();
    }

    _filteredActivities = result;
    notifyListeners();
  }

  // Generate unique activity ID
  Future<String> _generateActivityId() async {
    final year = DateTime.now().year;
    final snapshot =
        await _db
            .collection('activities')
            .where('activityId', isGreaterThanOrEqualTo: 'ACT-$year-')
            .where('activityId', isLessThan: 'ACT-${year + 1}-')
            .orderBy('activityId', descending: true)
            .limit(1)
            .get();

    int sequence = 1;
    if (snapshot.docs.isNotEmpty) {
      final lastActivityId =
          snapshot.docs.first.data()['activityId'] as String?;
      if (lastActivityId != null) {
        final parts = lastActivityId.split('-');
        if (parts.length == 3) {
          sequence = (int.tryParse(parts[2]) ?? 0) + 1;
        }
      }
    }

    return 'ACT-$year-${sequence.toString().padLeft(6, '0')}';
  }

  // Create activity
  Future<bool> createActivity({
    required String activityType,
    required String title,
    required String location,
    required String venue,
    required DateTime activityDate,
    required String startTime,
    required String endTime,
    required String topic,
    required String specialRequirements,
    required String urgency,
    int? expectedAttendance,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activityId = await _generateActivityId();

      await _db.collection('activities').add({
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
        'urgency': urgency,
        'expectedAttendance': expectedAttendance,
        'status': 'Available',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      await loadActivities();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to create activity: $error';
      notifyListeners();
      return false;
    }
  }

  // Update activity
  Future<bool> updateActivity(
    String docId, {
    required String activityType,
    required String title,
    required String location,
    required String venue,
    required DateTime activityDate,
    required String startTime,
    required String endTime,
    required String topic,
    required String specialRequirements,
    required String urgency,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db.collection('activities').doc(docId).update({
        'activityType': activityType,
        'title': title,
        'location': location,
        'venue': venue,
        'activityDate': Timestamp.fromDate(activityDate),
        'startTime': startTime,
        'endTime': endTime,
        'topic': topic,
        'specialRequirements': specialRequirements,
        'urgency': urgency,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      await loadActivities();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to update activity: $error';
      notifyListeners();
      return false;
    }
  }

  // Delete activity
  Future<bool> deleteActivity(String docId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db.collection('activities').doc(docId).delete();
      _isLoading = false;
      await loadActivities();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to delete activity: $error';
      notifyListeners();
      return false;
    }
  }

  // Get activity submission
  Future<ActivitySubmission?> getActivitySubmission(String activityId) async {
    try {
      final snapshot =
          await _db
              .collection('activity_submissions')
              .where('activityId', isEqualTo: activityId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return ActivitySubmission.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (error) {
      _errorMessage = 'Failed to load submission: $error';
      notifyListeners();
      return null;
    }
  }

  // ============================================================================
  // MODULE INTEGRATION: Activity → Payment → KPI
  // ============================================================================
  // TRIGGER: Officer approves activity submission
  // FLOW:
  //   1. Update activity_submissions.status = 'Approved'
  //   2. Update activities.status = 'Approved'
  //   3. CREATE pending payment record (Payment Module)
  //   4. UPDATE kpi_progress.sessions_completed +1 (KPI Module)
  //   5. CREATE integration_logs entry for audit trail
  //   6. Mark integration as completed
  //
  // SHARED DATA:
  //   - activityId: Links activity to payment and KPI
  //   - submissionId: Links back to evidence submission
  //   - preacherId: Identifies which preacher to credit
  //   - activityDate: Used for chronological tracking
  //
  // CONSUMER MODULES:
  //   - Payment Module: Reads 'payments' collection, status='Pending'
  //   - KPI Module: Reads 'kpi_progress' collection
  //
  // AUDITABILITY:
  //   - integration_logs: Full audit trail of all integrations
  //   - Timestamps: reviewedAt, approvedAt, integratedAt
  //   - Status tracking: integrationStatus field
  // ============================================================================
  Future<bool> approveSubmission(String activityId, String submissionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final batch = _db.batch();

      // STEP 1: Update submission status with audit trail
      batch.update(_db.collection('activity_submissions').doc(submissionId), {
        'status': 'Approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': 'Officer', // Add officer tracking if needed
        'integrationStatus': 'processing', // Track integration state
      });

      // Get activity data for payment and KPI
      final activityQuery =
          await _db
              .collection('activities')
              .where('activityId', isEqualTo: activityId)
              .limit(1)
              .get();

      if (activityQuery.docs.isNotEmpty) {
        final activityDoc = activityQuery.docs.first;
        final activityData = activityDoc.data();

        // STEP 2: Update activity status
        batch.update(_db.collection('activities').doc(activityDoc.id), {
          'status': 'Approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final preacherId = activityData['assignedPreacherId'] as String?;
        final preacherName = activityData['assignedPreacherName'] as String?;

        if (preacherId != null && preacherName != null) {
          // Check if payment already exists to prevent duplicates
          final existingPayment =
              await _db
                  .collection('payment')
                  .where('activityId', isEqualTo: activityId)
                  .limit(1)
                  .get();

          if (existingPayment.docs.isEmpty) {
            // STEP 3: CREATE PENDING PAYMENT for the preacher
            // This integrates with Payment Module
            final paymentRef = _db.collection('payment').doc();
            final paymentId = 'PAY${DateTime.now().millisecondsSinceEpoch}';

            batch.set(paymentRef, {
              'paymentId': paymentId,
              'activityId': activityId,
              'activityName': activityData['title'] ?? 'Activity',
              'preacherId': preacherId,
              'preacherName': preacherName,
              'activityDate': activityData['activityDate'],
              'amount': 100.0, // Default amount, officer can edit later
              'paymentAmount': 100.0,
              'status': 'Pending Payment',
              'verificationSource': 'activity_approval', // Audit: Track source
              'verificationDate': FieldValue.serverTimestamp(),
              'submissionId': submissionId, // Link back to submission
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            // STEP 4: UPDATE KPI PROGRESS for the preacher
            // This integrates with KPI Module
            final kpiQuery =
                await _db
                    .collection('kpi_targets')
                    .where('preacher_id', isEqualTo: preacherId)
                    .get();

            if (kpiQuery.docs.isNotEmpty) {
              final kpiId = kpiQuery.docs.first.id;

              // Check if progress exists
              final progressQuery =
                  await _db
                      .collection('kpi_progress')
                      .where('kpi_id', isEqualTo: kpiId)
                      .where('preacher_id', isEqualTo: preacherId)
                      .limit(1)
                      .get();

              if (progressQuery.docs.isNotEmpty) {
                // Update existing progress
                final progressDoc = progressQuery.docs.first;
                final currentSessions =
                    (progressDoc.data()['sessions_completed'] ?? 0) as int;
                final currentAttendance =
                    (progressDoc.data()['total_attendance_achieved'] ?? 0)
                        as int;
                final expectedAttendance =
                    activityData['expectedAttendance'] as int? ?? 0;

                batch.update(
                  _db.collection('kpi_progress').doc(progressDoc.id),
                  {
                    'sessions_completed': currentSessions + 1,
                    'total_attendance_achieved':
                        currentAttendance + expectedAttendance,
                    'last_updated': FieldValue.serverTimestamp(),
                    'last_activity_id':
                        activityId, // Audit: Track which activity
                    'last_activity_date': activityData['activityDate'],
                  },
                );
              } else {
                // Create new progress record for this preacher
                final progressRef = _db.collection('kpi_progress').doc();
                final expectedAttendance =
                    activityData['expectedAttendance'] as int? ?? 0;

                batch.set(progressRef, {
                  'kpi_id': kpiId,
                  'preacher_id': preacherId,
                  'sessions_completed': 1,
                  'total_attendance_achieved': expectedAttendance,
                  'new_converts_achieved': 0,
                  'baptisms_achieved': 0,
                  'community_projects_achieved': 0,
                  'charity_events_achieved': 0,
                  'youth_program_attendance_achieved': 0,
                  'overall_percentage': 0.0,
                  'performance_status': 'new',
                  'performance_points': 0,
                  'ranking': 0,
                  'last_activity_id': activityId, // Audit: Track first activity
                  'last_activity_date': activityData['activityDate'],
                  'last_updated': FieldValue.serverTimestamp(),
                });
              }
            }

            // STEP 5: Create integration audit log
            final auditRef = _db.collection('integration_logs').doc();
            batch.set(auditRef, {
              'event': 'activity_approved',
              'activityId': activityId,
              'submissionId': submissionId,
              'preacherId': preacherId,
              'preacherName': preacherName,
              'paymentCreated':
                  existingPayment.docs.isEmpty, // True if new payment created
              'paymentAlreadyExists':
                  existingPayment.docs.isNotEmpty, // True if skipped
              'kpiUpdated': kpiQuery.docs.isNotEmpty,
              'timestamp': FieldValue.serverTimestamp(),
              'status': 'success',
            });
          } // Close duplicate check
        }
      }

      await batch.commit();

      // STEP 6: Mark integration as complete
      await _db.collection('activity_submissions').doc(submissionId).update({
        'integrationStatus': 'completed',
        'integratedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      await loadActivities();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to approve submission: $error';
      notifyListeners();
      return false;
    }
  }

  // Reject submission
  Future<bool> rejectSubmission(
    String activityId,
    String submissionId,
    String reviewNotes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final batch = _db.batch();

      // Update submission status
      batch.update(_db.collection('activity_submissions').doc(submissionId), {
        'status': 'Rejected',
        'reviewNotes': reviewNotes,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      // Update activity status
      final activityQuery =
          await _db
              .collection('activities')
              .where('activityId', isEqualTo: activityId)
              .limit(1)
              .get();

      if (activityQuery.docs.isNotEmpty) {
        batch.update(
          _db.collection('activities').doc(activityQuery.docs.first.id),
          {'status': 'Rejected', 'updatedAt': FieldValue.serverTimestamp()},
        );
      }

      await batch.commit();
      _isLoading = false;
      await loadActivities();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to reject submission: $error';
      notifyListeners();
      return false;
    }
  }
}
