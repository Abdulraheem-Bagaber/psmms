import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _search = '';
  String _region = 'All';
  String _specialization = 'All';
  DocumentSnapshot? _lastDoc;
  String? _error;

  Preacher? _selected;
  PreacherMetrics? _metrics;
  bool _isDetailLoading = false;
  String? _detailError;

  List<Preacher> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get search => _search;
  String get region => _region;
  String get specialization => _specialization;

  Preacher? get selected => _selected;
  PreacherMetrics? get metrics => _metrics;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

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
    _metrics = null;
    _detailError = null;
    _isDetailLoading = true;
    notifyListeners();

    try {
      final metrics = await _computeMetrics(preacher.preacherId);
      _metrics = metrics;
      _isDetailLoading = false;
      notifyListeners();
    } catch (e) {
      _detailError = 'Failed to load metrics: $e';
      _isDetailLoading = false;
      notifyListeners();
    }
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
}
