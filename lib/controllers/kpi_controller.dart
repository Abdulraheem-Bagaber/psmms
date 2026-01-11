// Provider Controller: KPIController
// Component Name for SDD: KPIController
// Package: com.muip.psm.controllers

import 'package:flutter/foundation.dart';
import '../models/KPITarget.dart';
import '../models/KPIProgress.dart';
import '../services/firestore_service.dart';

/// State management controller for KPI operations
/// Handles KPI target management and progress tracking
class KPIController extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  
  KPI? _currentKPI;
  KPIProgress? _currentProgress;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  
  // Getters
  KPI? get currentKPI => _currentKPI;
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
  Future<void> loadKPI(String preacherId, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final kpis = await _db.getKPITargetsByPreacher(preacherId).first;
      _currentKPI = kpis.isNotEmpty ? kpis.first : null;
      
      if (_currentKPI != null) {
        _currentProgress = await _db.getKPIProgress(_currentKPI!.id!, preacherId);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load KPI: $e';
      _isLoading = false;
      notifyListeners();
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
    if (monthlySessionTarget <= 0 || totalAttendanceTarget <= 0 ||
        newConvertsTarget <= 0 || baptismsTarget <= 0 ||
        communityProjectsTarget <= 0 || charityEventsTarget <= 0 ||
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
      final existingKPIs = await _db.getKPITargetsByPreacher(preacherId).first;
      final existingKPI = existingKPIs.isNotEmpty ? existingKPIs.first : null;
      
      if (existingKPI != null) {
        // Update existing KPI
        final updatedKPI = existingKPI.copyWith(
          monthlySessionTarget: monthlySessionTarget,
          totalAttendanceTarget: totalAttendanceTarget,
          newConvertsTarget: newConvertsTarget,
          baptismsTarget: baptismsTarget,
          communityProjectsTarget: communityProjectsTarget,
          charityEventsTarget: charityEventsTarget,
          youthProgramAttendanceTarget: youthProgramAttendanceTarget,
        );
        
        await _db.updateKPITarget(existingKPI.id!, updatedKPI);
        _currentKPI = updatedKPI;
        _successMessage = 'KPI targets updated successfully';
      } else {
        // Create new KPI
        final newKPI = KPI(
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
        
        final kpiId = await _db.addKPITarget(newKPI);
        _currentKPI = newKPI.copyWith(id: kpiId);
        
        // Create initial progress record
        await _db.initializeKPIProgress(kpiId, preacherId);
        _currentProgress = await _db.getKPIProgress(kpiId, preacherId);
        
        _successMessage = 'KPI targets saved successfully';
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
      final kpis = await _db.getKPITargetsByPreacher(preacherId).first;
      
      if (kpis.isEmpty) {
        _error = 'Your performance targets have not been set for this period. Please contact your Officer.';
        _currentKPI = null;
        _currentProgress = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Get most recent KPI
      _currentKPI = kpis.first;
      _currentProgress = await _db.getKPIProgress(_currentKPI!.id!, preacherId);
      
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
    required int preacherId,
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
        sessionsCompleted: _currentProgress!.sessionsCompleted + (sessionsIncrement ?? 0),
        totalAttendanceAchieved: _currentProgress!.totalAttendanceAchieved + (attendanceIncrement ?? 0),
        newConvertsAchieved: _currentProgress!.newConvertsAchieved + (convertsIncrement ?? 0),
        baptismsAchieved: _currentProgress!.baptismsAchieved + (baptismsIncrement ?? 0),
        communityProjectsAchieved: _currentProgress!.communityProjectsAchieved + (projectsIncrement ?? 0),
        charityEventsAchieved: _currentProgress!.charityEventsAchieved + (eventsIncrement ?? 0),
        youthProgramAttendanceAchieved: _currentProgress!.youthProgramAttendanceAchieved + (youthAttendanceIncrement ?? 0),
        lastUpdated: DateTime.now(),
      );
      
      await _db.setKPIProgress(updatedProgress);
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
