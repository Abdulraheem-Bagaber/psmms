import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../models/activity.dart';
import '../models/activity_submission.dart';

enum ActivityFilterType { nearest, newest, urgent }

class PreacherActivityViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  List<Activity> _availableActivities = [];
  List<Activity> _filteredActivities = [];
  List<Activity> _myActivities = [];
  List<Activity> _filteredMyActivities = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  ActivityFilterType _filterType = ActivityFilterType.newest;
  String _myActivitiesStatus = 'Upcoming';
  String? _currentPreacherId; // Store preacher ID

  List<Activity> get availableActivities => _filteredActivities;
  List<Activity> get myActivities => _filteredMyActivities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ActivityFilterType get filterType => _filterType;
  String get myActivitiesStatus => _myActivitiesStatus;

  List<XFile> _selectedImages = [];
  List<XFile> get selectedImages => _selectedImages;

  // Load available activities (for Apply screen)
  Future<void> loadAvailableActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('activities')
          .where('status', isEqualTo: 'Available')
          .get();

      _availableActivities = snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      _applyAvailableFilters();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to load activities: $error';
      notifyListeners();
    }
  }

  // Load my activities (for My Activities screen)
  Future<void> loadMyActivities(String preacherId) async {
    _currentPreacherId = preacherId; // Store preacher ID
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('activities')
          .where('assignedPreacherId', isEqualTo: preacherId)
          .get();

      _myActivities = snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      print('Loaded ${_myActivities.length} activities for preacher $preacherId'); // Debug
      _applyMyActivitiesFilters();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to load my activities: $error';
      print('Error loading activities: $error'); // Debug
      notifyListeners();
    }
  }

  // Search and filter for available activities
  void onSearchChanged(String query) {
    _searchQuery = query.trim();
    _applyAvailableFilters();
  }

  void onFilterTypeChanged(ActivityFilterType type) {
    _filterType = type;
    _applyAvailableFilters();
  }

  void _applyAvailableFilters() {
    List<Activity> result = List.from(_availableActivities);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((a) =>
        a.title.toLowerCase().contains(query) ||
        a.location.toLowerCase().contains(query) ||
        a.topic.toLowerCase().contains(query)
      ).toList();
    }

    // Apply filter type
    switch (_filterType) {
      case ActivityFilterType.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ActivityFilterType.nearest:
        // TODO: Implement distance sorting based on current location
        result.sort((a, b) => a.location.compareTo(b.location));
        break;
      case ActivityFilterType.urgent:
        // Filter by urgency field set by officer
        result = result.where((a) => a.urgency == 'Urgent').toList();
        result.sort((a, b) => a.activityDate.compareTo(b.activityDate));
        break;
    }

    _filteredActivities = result;
    notifyListeners();
  }

  // Filter my activities by status
  void onMyActivitiesStatusChanged(String status) {
    _myActivitiesStatus = status;
    _applyMyActivitiesFilters();
  }

  void _applyMyActivitiesFilters() {
    List<Activity> result = List.from(_myActivities);

    print('Filtering ${_myActivities.length} activities with status filter: $_myActivitiesStatus'); // Debug

    // Filter by status
    if (_myActivitiesStatus == 'Upcoming') {
      // Show all Assigned activities (upcoming or not yet submitted)
      result = result.where((a) => a.status == 'Assigned').toList();
      print('Found ${result.length} Assigned activities'); // Debug
    } else if (_myActivitiesStatus == 'Pending') {
      result = result.where((a) => a.status == 'Submitted').toList();
      print('Found ${result.length} Submitted activities'); // Debug
    } else if (_myActivitiesStatus == 'Approved') {
      result = result.where((a) => 
        a.status == 'Approved' || a.status == 'Approved by MUIP Officer'
      ).toList();
    } else if (_myActivitiesStatus == 'Rejected') {
      result = result.where((a) => a.status == 'Rejected').toList();
    }

    _filteredMyActivities = result;
    notifyListeners();
  }

  // Apply for activity
  Future<bool> applyForActivity(String activityId, String activityDocId, String preacherId, String preacherName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Applying for activity: $activityDocId with preacher: $preacherId'); // Debug
      await _db.collection('activities').doc(activityDocId).update({
        'assignedPreacherId': preacherId,
        'assignedPreacherName': preacherName,
        'status': 'Assigned',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Successfully applied! Now reloading...'); // Debug
      _isLoading = false;
      
      // Reload both available and my activities
      await loadAvailableActivities();
      if (_currentPreacherId != null) {
        await loadMyActivities(_currentPreacherId!);
      }
      
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to apply for activity: $error';
      print('Error applying: $error'); // Debug
      notifyListeners();
      return false;
    }
  }

  // Image selection
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        // Limit to 3 photos
        _selectedImages = images.take(3).toList();
        notifyListeners();
      }
    } catch (error) {
      _errorMessage = 'Failed to select images: $error';
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled';
        notifyListeners();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied';
          notifyListeners();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission permanently denied';
        notifyListeners();
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (error) {
      _errorMessage = 'Failed to get location: $error';
      notifyListeners();
      return null;
    }
  }

  // Upload images to Firebase Storage
  Future<List<String>> _uploadImages(String activityId) async {
    List<String> photoUrls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final file = File(_selectedImages[i].path);
        final fileName = '${activityId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = _storage.ref().child('activity_submissions/$activityId/$fileName');
        
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        photoUrls.add(url);
      } catch (error) {
        print('Failed to upload image $i: $error');
      }
    }

    return photoUrls;
  }

  // Submit activity evidence
  Future<bool> submitEvidence({
    required String activityId,
    required String activityDocId,
    required String preacherId,
    required String preacherName,
  }) async {
    if (_selectedImages.isEmpty) {
      _errorMessage = 'Please upload at least one photo';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      final position = await getCurrentLocation();
      if (position == null) {
        _isLoading = false;
        return false;
      }

      // Upload images
      final photoUrls = await _uploadImages(activityId);
      if (photoUrls.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Failed to upload photos';
        notifyListeners();
        return false;
      }

      // Create submission document
      await _db.collection('activity_submissions').add({
        'activityId': activityId,
        'preacherId': preacherId,
        'preacherName': preacherName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'photoUrls': photoUrls,
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });

      // Update activity status
      await _db.collection('activities').doc(activityDocId).update({
        'status': 'Submitted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _selectedImages.clear();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to submit evidence: $error';
      notifyListeners();
      return false;
    }
  }

  // Get activity submission for viewing
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
}
