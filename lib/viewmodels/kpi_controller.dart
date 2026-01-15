import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/kpi_target.dart';
import '../models/kpi_progress.dart';

/// State management controller for KPI operations
/// Handles KPI target management and progress tracking
class KPIController extends ChangeNotifier {
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
      // Fetch all KPIs for preacher and filter in memory to avoid composite index
      final snapshot =
          await _db
              .collection('kpi_targets')
              .where('preacher_id', isEqualTo: preacherId)
              .get();

      if (snapshot.docs.isNotEmpty) {
        // Filter in memory for overlapping date ranges
        final matchingDocs =
            snapshot.docs.where((doc) {
              final kpi = KPITarget.fromFirestore(doc);
              return kpi.startDate.isBefore(
                    endDate.add(const Duration(days: 1)),
                  ) &&
                  kpi.endDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  );
            }).toList();

        if (matchingDocs.isNotEmpty) {
          _currentKPI = KPITarget.fromFirestore(matchingDocs.first);
          // Load corresponding progress
          await _loadProgress(_currentKPI!.id!);
        } else {
          _currentKPI = null;
          _currentProgress = null;
        }
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
      print('DEBUG: Saving KPI for preacher ID: $preacherId'); // Debug log

      // Check if KPI already exists - fetch all for preacher and filter in memory
      final existingSnapshot =
          await _db
              .collection('kpi_targets')
              .where('preacher_id', isEqualTo: preacherId)
              .get();

      // Filter in memory for overlapping date ranges
      final matchingDocs =
          existingSnapshot.docs.where((doc) {
            final kpi = KPITarget.fromFirestore(doc);
            return kpi.startDate.isBefore(
                  endDate.add(const Duration(days: 1)),
                ) &&
                kpi.endDate.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                );
          }).toList();

      if (matchingDocs.isNotEmpty) {
        // Update existing KPI
        final docId = matchingDocs.first.id;
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
          targetTarbiah: 0,
          targetDakwah: 0,
          targetAqidah: 0,
          targetIrtiqak: 0,
          targetKhidmat: 0,
          targetDonations: 0.0,
          targetActivities: 0,
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
        final progress = KPIProgress(id: docRef.id, preacherId: preacherId);

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
      print('DEBUG: Loading KPI for preacher ID: $preacherId'); // Debug log

      // Get all KPIs for preacher
      final kpiSnapshot =
          await _db
              .collection('kpi_targets')
              .where('preacher_id', isEqualTo: preacherId)
              .get();

      print(
        'DEBUG: Found ${kpiSnapshot.docs.length} KPI documents',
      ); // Debug log

      if (kpiSnapshot.docs.isEmpty) {
        _currentKPI = null;
        _currentProgress = null;
        _error = 'No KPI targets set for this preacher';
      } else {
        // Sort by created_at in memory and get the most recent
        final sortedDocs =
            kpiSnapshot.docs.toList()..sort((a, b) {
              final aTime =
                  (a.data()['created_at'] as Timestamp?)?.toDate() ??
                  DateTime(2000);
              final bTime =
                  (b.data()['created_at'] as Timestamp?)?.toDate() ??
                  DateTime(2000);
              return bTime.compareTo(aTime); // descending order
            });

        _currentKPI = KPITarget.fromFirestore(sortedDocs.first);
        print('DEBUG: Loaded KPI with ID: ${_currentKPI!.id}'); // Debug log
        await _loadProgress(_currentKPI!.id!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('DEBUG: Error loading KPI: $e'); // Debug log
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
        updatedAt: DateTime.now(),
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

  // ==================== PERFORMANCE & RANKING SYSTEM ====================

  /// Calculate performance and assign points based on achievement percentage
  Future<Map<String, dynamic>> calculatePerformance(String preacherId) async {
    try {
      // Get current KPI target and progress
      final targetSnapshot =
          await _db
              .collection('kpi_targets')
              .where('preacher_id', isEqualTo: preacherId)
              .orderBy('created_at', descending: true)
              .limit(1)
              .get();

      if (targetSnapshot.docs.isEmpty) {
        return {'status': 'no_target', 'message': 'No KPI targets set'};
      }

      final target = KPITarget.fromFirestore(targetSnapshot.docs.first);

      final progressSnapshot =
          await _db
              .collection('kpi_progress')
              .where('preacher_id', isEqualTo: preacherId)
              .where('kpi_id', isEqualTo: target.id)
              .get();

      if (progressSnapshot.docs.isEmpty) {
        return {'status': 'no_progress', 'message': 'No progress recorded'};
      }

      final progressDoc = progressSnapshot.docs.first;
      final progress = KPIProgress.fromFirestore(progressDoc);

      // Calculate individual percentages
      List<double> percentages = [];
      if (target.monthlySessionTarget > 0) {
        percentages.add(
          (progress.sessionsCompleted / target.monthlySessionTarget) * 100,
        );
      }
      if (target.totalAttendanceTarget > 0) {
        percentages.add(
          (progress.totalAttendanceAchieved / target.totalAttendanceTarget) *
              100,
        );
      }
      if (target.newConvertsTarget > 0) {
        percentages.add(
          (progress.newConvertsAchieved / target.newConvertsTarget) * 100,
        );
      }
      if (target.baptismsTarget > 0) {
        percentages.add(
          (progress.baptismsAchieved / target.baptismsTarget) * 100,
        );
      }
      if (target.communityProjectsTarget > 0) {
        percentages.add(
          (progress.communityProjectsAchieved /
                  target.communityProjectsTarget) *
              100,
        );
      }
      if (target.charityEventsTarget > 0) {
        percentages.add(
          (progress.charityEventsAchieved / target.charityEventsTarget) * 100,
        );
      }
      if (target.youthProgramAttendanceTarget > 0) {
        percentages.add(
          (progress.youthProgramAttendanceAchieved /
                  target.youthProgramAttendanceTarget) *
              100,
        );
      }

      // Calculate overall percentage
      double overall =
          percentages.isEmpty
              ? 0.0
              : percentages.reduce((a, b) => a + b) / percentages.length;

      // Determine status and points
      String status;
      int points;
      String emoji;

      if (overall >= 90) {
        status = 'excellent';
        points = 100;
        emoji = '🏆';
      } else if (overall >= 70) {
        status = 'good';
        points = 70;
        emoji = '✅';
      } else if (overall >= 50) {
        status = 'warning';
        points = 40;
        emoji = '⚠️';
      } else {
        status = 'critical';
        points = 0;
        emoji = '🚨';
      }

      // Update progress with performance data
      await _db.collection('kpi_progress').doc(progressDoc.id).update({
        'overall_percentage': overall,
        'performance_status': status,
        'performance_points': points,
        'last_updated': FieldValue.serverTimestamp(),
      });

      return {
        'status': status,
        'percentage': overall,
        'points': points,
        'emoji': emoji,
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Update rankings for all preachers based on performance points
  Future<void> updateRankings() async {
    try {
      // Get all progress records sorted by points
      final progressSnapshot =
          await _db
              .collection('kpi_progress')
              .orderBy('performance_points', descending: true)
              .orderBy('overall_percentage', descending: true)
              .get();

      // Update ranking for each preacher
      int rank = 1;
      for (var doc in progressSnapshot.docs) {
        await _db.collection('kpi_progress').doc(doc.id).update({
          'ranking': rank,
        });
        rank++;
      }
    } catch (e) {
      print('Error updating rankings: $e');
    }
  }

  /// Get top performers (leaderboard)
  Future<List<Map<String, dynamic>>> getTopPerformers({int limit = 10}) async {
    try {
      final progressSnapshot =
          await _db
              .collection('kpi_progress')
              .orderBy('performance_points', descending: true)
              .orderBy('overall_percentage', descending: true)
              .limit(limit)
              .get();

      List<Map<String, dynamic>> topPerformers = [];

      for (var doc in progressSnapshot.docs) {
        final progress = KPIProgress.fromFirestore(doc);

        // Get preacher details
        final preacherSnapshot =
            await _db.collection('preachers').doc(progress.preacherId).get();

        if (preacherSnapshot.exists) {
          final preacherData = preacherSnapshot.data() as Map<String, dynamic>;
          topPerformers.add({
            'preacherId': progress.preacherId,
            'name': preacherData['fullName'] ?? 'Unknown',
            'region': preacherData['region'] ?? 'N/A',
            'points': progress.performancePoints,
            'percentage': progress.overallPercentage,
            'status': progress.performanceStatus,
            'ranking': progress.ranking,
          });
        }
      }

      return topPerformers;
    } catch (e) {
      print('Error getting top performers: $e');
      return [];
    }
  }

  /// Get preacher's current ranking
  Future<int> getPreacherRanking(String preacherId) async {
    try {
      final progressSnapshot =
          await _db
              .collection('kpi_progress')
              .where('preacher_id', isEqualTo: preacherId)
              .limit(1)
              .get();

      if (progressSnapshot.docs.isNotEmpty) {
        final progress = KPIProgress.fromFirestore(progressSnapshot.docs.first);
        return progress.ranking;
      }
      return 0;
    } catch (e) {
      print('Error getting ranking: $e');
      return 0;
    }
  }
}
