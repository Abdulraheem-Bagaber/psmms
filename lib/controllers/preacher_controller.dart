// Provider Controller: PreacherController
// Component Name for SDD: PreacherController
// Package: com.muip.psm.controllers

import 'package:flutter/foundation.dart';
import '../models/User.dart';
import '../services/firestore_service.dart';

/// State management controller for Preacher operations
/// Uses Provider pattern for reactive UI updates
class PreacherController extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  
  List<Preacher> _preachers = [];
  List<Preacher> _filteredPreachers = [];
  Preacher? _selectedPreacher;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Preacher> get preachers => _preachers;
  List<Preacher> get filteredPreachers => _filteredPreachers;
  Preacher? get selectedPreacher => _selectedPreacher;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all preachers from database
  Future<void> loadPreachers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _preachers = await _db.getPreachers().first;
      _filteredPreachers = _preachers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load preachers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Search preachers by name
  Future<void> searchPreachers(String query) async {
    if (query.isEmpty) {
      _filteredPreachers = _preachers;
    } else {
      _filteredPreachers = _preachers
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
  
  // Select a preacher
  void selectPreacher(Preacher preacher) {
    _selectedPreacher = preacher;
    notifyListeners();
  }
  
  // Clear selected preacher
  void clearSelection() {
    _selectedPreacher = null;
    notifyListeners();
  }
  
  // Get preacher by ID
  Future<Preacher?> getPreacherById(String id) async {
    try {
      return await _db.getPreacherById(id);
    } catch (e) {
      _error = 'Failed to get preacher: $e';
      notifyListeners();
      return null;
    }
  }
}
