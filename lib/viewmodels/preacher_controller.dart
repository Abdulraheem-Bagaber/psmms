import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/activity.dart';
import '../models/preacher.dart';
import '../services/preacher_api_handler.dart';

class PreacherMetrics {
  final int totalActivities;
  final int approvedActivities;
  final int rejectedActivities;
  final int submittedActivities;
  final double approvalRate;
  final double totalPayments;
  final DateTime? lastPaymentDate;

  const PreacherMetrics({
    required this.totalActivities,
    required this.approvedActivities,
    required this.rejectedActivities,
    required this.submittedActivities,
    required this.approvalRate,
    required this.totalPayments,
    required this.lastPaymentDate,
  });
}

class PreacherController extends ChangeNotifier {
  PreacherController({
    PreacherAPIHandler? apiHandler,
    FirebaseFirestore? firestore,
  }) : _api = apiHandler ?? PreacherAPIHandler(firestore: firestore),
       _db = firestore ?? FirebaseFirestore.instance;

  final PreacherAPIHandler _api;
  final FirebaseFirestore _db;

  List<Preacher> _items = [];
  List<Preacher> _preachers = []; // Alias for compatibility
  List<Preacher> _filteredPreachers = []; // For search/filter results
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _search = '';
  String _region = 'All';
  String _specialization = 'All';
  DocumentSnapshot? _lastDoc;
  String? _error;

  Preacher? _selected;
  Preacher? _selectedPreacher; // Alias for compatibility
  PreacherMetrics? _metrics;
  bool _isDetailLoading = false;
  String? _detailError;
  List<Activity> _trainingSchedules = [];
  bool _isTrainingLoading = false;
  String? _trainingError;

  List<Preacher> get items => _items;
  List<Preacher> get preachers => _preachers; // Alias getter
  List<Preacher> get filteredPreachers => _filteredPreachers;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get search => _search;
  String get region => _region;
  String get specialization => _specialization;

  Preacher? get selected => _selected;
  Preacher? get selectedPreacher => _selectedPreacher; // Alias getter
  PreacherMetrics? get metrics => _metrics;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  List<Activity> get trainingSchedules => _trainingSchedules;
  bool get isTrainingLoading => _isTrainingLoading;
  String? get trainingError => _trainingError;

  Future<void> loadInitial() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _api.fetchPreachers(
        search: _search,
        region: _region,
        specialization: _specialization,
        limit: 20,
      );
      _items = page.items;
      _preachers = page.items; // Sync alias
      _filteredPreachers = page.items; // Sync filtered list
      _lastDoc = page.lastDocument;
      _hasMore = page.items.length == 20;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load preachers: $e';
      notifyListeners();
    }
  }

  /// Loads all preachers - alias for loadInitial() for compatibility
  Future<void> loadPreachers() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _api.fetchPreachers(
        search: _search,
        region: _region,
        specialization: _specialization,
        limit: 20,
        startAfter: _lastDoc,
      );
      _items = [..._items, ...page.items];
      _lastDoc = page.lastDocument;
      _hasMore = page.items.length == 20;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _error = 'Failed to load more: $e';
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    _search = value.trim();
    loadInitial();
  }

  /// Searches preachers by query - wrapper for compatibility
  Future<void> searchPreachers(String query) async {
    _search = query.trim();
    await loadInitial();
  }

  void onRegionChanged(String value) {
    _region = value;
    loadInitial();
  }

  void onSpecializationChanged(String value) {
    _specialization = value;
    loadInitial();
  }

  Future<void> selectPreacher(Preacher preacher) async {
    _selected = preacher;
    _selectedPreacher = preacher; // Sync alias
    _metrics = null;
    _detailError = null;
    _isDetailLoading = true;
    _trainingSchedules = [];
    _trainingError = null;
    _isTrainingLoading = true;
    notifyListeners();

    try {
      final metricsFuture = _computeMetrics(preacher.preacherId);
      final trainingFuture = loadTrainingSchedules(preacher.preacherId);

      _metrics = await metricsFuture;
      await trainingFuture;

      _isDetailLoading = false;
      notifyListeners();
    } catch (e) {
      _detailError = 'Failed to load metrics: $e';
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  /// Clears the currently selected preacher
  void clearSelection() {
    _selected = null;
    _selectedPreacher = null;
    _metrics = null;
    _detailError = null;
    notifyListeners();
  }

  Future<void> refreshSelected() async {
    final target = _selected;
    if (target == null) return;
    final updated = await _api.getPreacherById(target.preacherId);
    if (updated != null) {
      _selected = updated;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String docId, Map<String, dynamic> data) async {
    await _api.updatePreacher(docId, data);
    await refreshSelected();
  }

  Future<void> createPreacher(Map<String, dynamic> data) async {
    final preacher = Preacher(
      id: '',
      preacherId: '',
      fullName: data['fullName'] ?? '',
      email:
          (data['email'] as String?)?.isNotEmpty == true ? data['email'] : null,
      phone:
          (data['phone'] as String?)?.isNotEmpty == true ? data['phone'] : null,
      region: data['region'] ?? '',
      specialization: List<String>.from(data['specialization'] ?? const []),
      skills: List<String>.from(data['skills'] ?? const []),
      bio: (data['bio'] as String?)?.isNotEmpty == true ? data['bio'] : null,
      status: 'Active',
      rating: 0,
      completedActivities: 0,
      approvedActivities: 0,
      rejectedActivities: 0,
      paymentsTotal: 0,
      lastPaymentDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _api.createPreacher(preacher);
    await loadInitial();
  }

  /// Gets a preacher by ID from Firestore
  Future<Preacher?> getPreacherById(String id) async {
    try {
      return await _api.getPreacherById(id);
    } catch (e) {
      _error = 'Failed to get preacher: $e';
      notifyListeners();
      return null;
    }
  }

  Future<PreacherMetrics> _computeMetrics(String preacherId) async {
    final activitiesSnap =
        await _db
            .collection('activities')
            .where('assignedPreacherId', isEqualTo: preacherId)
            .get();
    // final submissionsSnap =
    //     await _db
    //         .collection('activity_submissions')
    //         .where('preacherId', isEqualTo: preacherId)
    //         .get();
    final paymentsSnap =
        await _db
            .collection('payment')
            .where('preacherId', isEqualTo: preacherId)
            .get();

    int totalActivities = activitiesSnap.docs.length;
    int approvedActivities = 0;
    int rejectedActivities = 0;
    int submittedActivities = 0;

    for (final doc in activitiesSnap.docs) {
      final status = doc['status'] as String? ?? '';
      if (status == 'Approved') approvedActivities++;
      if (status == 'Rejected') rejectedActivities++;
      if (status == 'Submitted') submittedActivities++;
    }

    double totalPayments = 0;
    DateTime? lastPaymentDate;
    for (final doc in paymentsSnap.docs) {
      final data = doc.data();
      totalPayments +=
          ((data['amount'] ?? data['paymentAmount']) ?? 0).toDouble();
      final ts = data['activityDate'];
      DateTime? paidDate;
      if (ts is Timestamp) paidDate = ts.toDate();
      if (ts is String) paidDate = DateTime.tryParse(ts);
      if (paidDate != null) {
        if (lastPaymentDate == null || paidDate.isAfter(lastPaymentDate)) {
          lastPaymentDate = paidDate;
        }
      }
    }

    final approvalRate =
        totalActivities == 0
            ? 0.0
            : (approvedActivities / totalActivities) * 100;

    return PreacherMetrics(
      totalActivities: totalActivities,
      approvedActivities: approvedActivities,
      rejectedActivities: rejectedActivities,
      submittedActivities: submittedActivities,
      approvalRate: approvalRate,
      totalPayments: totalPayments,
      lastPaymentDate: lastPaymentDate,
    );
  }

  Future<void> loadTrainingSchedules(String preacherId) async {
    _isTrainingLoading = true;
    _trainingError = null;
    notifyListeners();

    try {
      final snapshot =
          await _db
              .collection('activities')
              .where('assignedPreacherId', isEqualTo: preacherId)
              .orderBy('activityDate', descending: false)
              .get();

      _trainingSchedules =
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      _isTrainingLoading = false;
      notifyListeners();
    } catch (e) {
      _trainingError = 'Failed to load training schedules: $e';
      _isTrainingLoading = false;
      notifyListeners();
    }
  }
}
