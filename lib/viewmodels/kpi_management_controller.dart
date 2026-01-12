import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/kpi_target.dart';
import '../models/kpi_progress.dart';

/// State management controller for KPI operations
/// Handles KPI target management and progress tracking
class KPIManagementController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  KPITarget? _currentKPI;
  KPIProgress? _currentProgress;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  KPITarget? get currentKPI => _currentKPI;
  KPIProgress? get currentProgress => _currentProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // ==================== KPI TARGET MANAGEMENT ====================

  // Load KPI for a preacher in a specific period
  Future<void> loadKPI(
    String preacherId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot =
          await _db
              .collection('kpi_targets')
              .where('preacher_id', isEqualTo: preacherId)
              .where(
                'start_date',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .where(
                'end_date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        _currentKPI = KPITarget.fromFirestore(snapshot.docs.first);

        // Load corresponding progress
        await _loadProgress(_currentKPI!.id!);
      } else {
        _currentKPI = null;
        _currentProgress = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load KPI: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load progress for a KPI
  Future<void> _loadProgress(String kpiId) async {
    try {
      final snapshot =
          await _db
              .collection('kpi_progress')
              .where('kpi_id', isEqualTo: kpiId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        _currentProgress = KPIProgress.fromFirestore(snapshot.docs.first);
      } else {
        _currentProgress = null;
      }
    } catch (e) {
      _error = 'Failed to load progress: $e';
    }
  }

  // Save new KPI targets (MUIP Official operation)
  Future<bool> saveKPITargets({
    required String preacherId,
    required int monthlySessionTarget,
    required int totalAttendanceTarget,
    required int newConvertsTarget,
    required int baptismsTarget,
    required int communityProjectsTarget,
    required int charityEventsTarget,
    required int youthProgramAttendanceTarget,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Validation: All targets must be positive integers
    if (monthlySessionTarget <= 0 ||
        totalAttendanceTarget <= 0 ||
        newConvertsTarget <= 0 ||
        baptismsTarget <= 0 ||
        communityProjectsTarget <= 0 ||
        charityEventsTarget <= 0 ||
        youthProgramAttendanceTarget <= 0) {
      _error = 'All KPI target values must be positive integers';
      notifyListeners();
      return false;
    }

    // Validation: Performance period must be valid
    if (endDate.isBefore(startDate)) {
      _error = 'End date must be after start date';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check if KPI already exists
      final existingSnapshot =
          await _db
              .collection('kpi_targets')
              .where('preacher_id', isEqualTo: preacherId)
              .where(
                'start_date',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .where(
                'end_date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .limit(1)
              .get();

      if (existingSnapshot.docs.isNotEmpty) {
        // Update existing KPI
        final docId = existingSnapshot.docs.first.id;
        await _db.collection('kpi_targets').doc(docId).update({
          'monthly_session_target': monthlySessionTarget,
          'total_attendance_target': totalAttendanceTarget,
          'new_converts_target': newConvertsTarget,
          'baptisms_target': baptismsTarget,
          'community_projects_target': communityProjectsTarget,
          'charity_events_target': charityEventsTarget,
          'youth_program_attendance_target': youthProgramAttendanceTarget,
          'start_date': Timestamp.fromDate(startDate),
          'end_date': Timestamp.fromDate(endDate),
          'updated_at': FieldValue.serverTimestamp(),
        });

        _successMessage = 'KPI targets updated successfully';
      } else {
        // Create new KPI
        final kpi = KPITarget(
          preacherId: preacherId,
          monthlySessionTarget: monthlySessionTarget,
          totalAttendanceTarget: totalAttendanceTarget,
          newConvertsTarget: newConvertsTarget,
          baptismsTarget: baptismsTarget,
          communityProjectsTarget: communityProjectsTarget,
          charityEventsTarget: charityEventsTarget,
          youthProgramAttendanceTarget: youthProgramAttendanceTarget,
          startDate: startDate,
          endDate: endDate,
        );

        final docRef = await _db
            .collection('kpi_targets')
            .add(kpi.toFirestore());

        // Create corresponding progress record
        final progress = KPIProgress(kpiId: docRef.id, preacherId: preacherId);

        await _db.collection('kpi_progress').add(progress.toFirestore());

        _successMessage = 'KPI targets created successfully';
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save KPI: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== PROGRESS TRACKING (Preacher View) ====================

  // Load KPI progress for preacher dashboard
  Future<void> loadPreacherProgress(String preacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get all KPIs for preacher
      final kpiSnapshot =
          await _db
              .collection('kpi_targets')
              .where('preacher_id', isEqualTo: preacherId)
              .orderBy('created_at', descending: true)
              .limit(1)
              .get();

      if (kpiSnapshot.docs.isEmpty) {
        _currentKPI = null;
        _currentProgress = null;
        _error = 'No KPI targets set for this preacher';
      } else {
        _currentKPI = KPITarget.fromFirestore(kpiSnapshot.docs.first);
        await _loadProgress(_currentKPI!.id!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load progress: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate overall progress percentage
  double calculateOverallProgress() {
    if (_currentKPI == null || _currentProgress == null) return 0.0;

    final metrics = [
      _currentProgress!.calculateProgress(
        _currentProgress!.sessionsCompleted,
        _currentKPI!.monthlySessionTarget,
      ),
      _currentProgress!.calculateProgress(
        _currentProgress!.totalAttendanceAchieved,
        _currentKPI!.totalAttendanceTarget,
      ),
      _currentProgress!.calculateProgress(
        _currentProgress!.newConvertsAchieved,
        _currentKPI!.newConvertsTarget,
      ),
      _currentProgress!.calculateProgress(
        _currentProgress!.baptismsAchieved,
        _currentKPI!.baptismsTarget,
      ),
      _currentProgress!.calculateProgress(
        _currentProgress!.communityProjectsAchieved,
        _currentKPI!.communityProjectsTarget,
      ),
      _currentProgress!.calculateProgress(
        _currentProgress!.charityEventsAchieved,
        _currentKPI!.charityEventsTarget,
      ),
      _currentProgress!.calculateProgress(
        _currentProgress!.youthProgramAttendanceAchieved,
        _currentKPI!.youthProgramAttendanceTarget,
      ),
    ];

    return metrics.reduce((a, b) => a + b) / metrics.length;
  }

  // Update progress from Activity Management module
  Future<void> updateProgressFromActivity({
    required String preacherId,
    int? sessionsIncrement,
    int? attendanceIncrement,
    int? convertsIncrement,
    int? baptismsIncrement,
    int? projectsIncrement,
    int? eventsIncrement,
    int? youthAttendanceIncrement,
  }) async {
    if (_currentProgress == null) return;

    try {
      final updatedProgress = _currentProgress!.copyWith(
        sessionsCompleted:
            _currentProgress!.sessionsCompleted + (sessionsIncrement ?? 0),
        totalAttendanceAchieved:
            _currentProgress!.totalAttendanceAchieved +
            (attendanceIncrement ?? 0),
        newConvertsAchieved:
            _currentProgress!.newConvertsAchieved + (convertsIncrement ?? 0),
        baptismsAchieved:
            _currentProgress!.baptismsAchieved + (baptismsIncrement ?? 0),
        communityProjectsAchieved:
            _currentProgress!.communityProjectsAchieved +
            (projectsIncrement ?? 0),
        charityEventsAchieved:
            _currentProgress!.charityEventsAchieved + (eventsIncrement ?? 0),
        youthProgramAttendanceAchieved:
            _currentProgress!.youthProgramAttendanceAchieved +
            (youthAttendanceIncrement ?? 0),
        lastUpdated: DateTime.now(),
      );

      await _db
          .collection('kpi_progress')
          .doc(_currentProgress!.id)
          .update(updatedProgress.toFirestore());
      _currentProgress = updatedProgress;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  // Clear current KPI data
  void clearKPI() {
    _currentKPI = null;
    _currentProgress = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
