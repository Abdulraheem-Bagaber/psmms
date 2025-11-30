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
      final snapshot = await _db
          .collection('activities')
          .orderBy('createdAt', descending: true)
          .get();

      _activities = snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
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
      result = result.where((a) =>
        a.title.toLowerCase().contains(query) ||
        a.location.toLowerCase().contains(query) ||
        (a.assignedPreacherName?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    _filteredActivities = result;
    notifyListeners();
  }

  // Generate unique activity ID
  Future<String> _generateActivityId() async {
    final year = DateTime.now().year;
    final snapshot = await _db
        .collection('activities')
        .where('activityId', isGreaterThanOrEqualTo: 'ACT-$year-')
        .where('activityId', isLessThan: 'ACT-${year + 1}-')
        .orderBy('activityId', descending: true)
        .limit(1)
        .get();

    int sequence = 1;
    if (snapshot.docs.isNotEmpty) {
      final lastActivityId = snapshot.docs.first.data()['activityId'] as String?;
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
      final snapshot = await _db
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

  // Approve submission
  Future<bool> approveSubmission(String activityId, String submissionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final batch = _db.batch();

      // Update submission status
      batch.update(
        _db.collection('activity_submissions').doc(submissionId),
        {
          'status': 'Approved',
          'reviewedAt': FieldValue.serverTimestamp(),
        },
      );

      // Update activity status
      final activityQuery = await _db
          .collection('activities')
          .where('activityId', isEqualTo: activityId)
          .limit(1)
          .get();

      if (activityQuery.docs.isNotEmpty) {
        batch.update(
          _db.collection('activities').doc(activityQuery.docs.first.id),
          {
            'status': 'Approved',
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
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
  Future<bool> rejectSubmission(String activityId, String submissionId, String reviewNotes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final batch = _db.batch();

      // Update submission status
      batch.update(
        _db.collection('activity_submissions').doc(submissionId),
        {
          'status': 'Rejected',
          'reviewNotes': reviewNotes,
          'reviewedAt': FieldValue.serverTimestamp(),
        },
      );

      // Update activity status
      final activityQuery = await _db
          .collection('activities')
          .where('activityId', isEqualTo: activityId)
          .limit(1)
          .get();

      if (activityQuery.docs.isNotEmpty) {
        batch.update(
          _db.collection('activities').doc(activityQuery.docs.first.id),
          {
            'status': 'Rejected',
            'updatedAt': FieldValue.serverTimestamp(),
          },
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
