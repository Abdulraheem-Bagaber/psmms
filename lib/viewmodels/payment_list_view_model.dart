import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/payment.dart';

enum PaymentListMode {
  officerPending,
  adminApproved,
  adminHistory,
  preacherHistory,
}

class PaymentListViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final PaymentListMode mode;
  final String? preacherId;

  List<Payment> _all = [];
  List<Payment> _visible = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'All';

  PaymentListViewModel({required this.mode, this.preacherId}) {
    loadPayments();
  }

  List<Payment> get payments => _visible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  Future<void> loadPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query query = _db.collection('payment');

      switch (mode) {
        case PaymentListMode.officerPending:
          query = query.where('status', isEqualTo: 'Pending Payment');
          break;
        case PaymentListMode.adminApproved:
          query = query.where('status', isEqualTo: 'Approved by MUIP Officer');
          break;
        case PaymentListMode.adminHistory:
          query = query.where(
            'status',
            whereIn: [
              'Pending Payment',
              'Forwarded to Yayasan',
              'Paid',
              'Rejected',
            ],
          );
          break;
        case PaymentListMode.preacherHistory:
          if (preacherId != null) {
            query = query.where('preacherId', isEqualTo: preacherId);
          }
          break;
      }

      final snapshot = await query.get();
      _all = snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList();
      _all.sort((a, b) => b.activityDate.compareTo(a.activityDate));

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to load payments: $error';
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  void onStatusFilterChanged(String label) {
    _statusFilter = label;
    _applyFilters();
  }

  void _applyFilters() {
    List<Payment> result = List.from(_all);

    // For adminHistory mode, ensure only specified statuses are shown
    if (mode == PaymentListMode.adminHistory) {
      result =
          result
              .where(
                (item) =>
                    item.status == 'Pending Payment' ||
                    item.status == 'Forwarded to Yayasan' ||
                    item.status == 'Paid' ||
                    item.status == 'Rejected',
              )
              .toList();
    }

    if (_statusFilter != 'All') {
      if (_statusFilter == 'Pending') {
        result =
            result.where((item) => item.status == 'Pending Payment').toList();
      } else if (_statusFilter == 'Approved') {
        result =
            result
                .where(
                  (item) =>
                      item.status == 'Approved by MUIP Officer' ||
                      item.status == 'Paid',
                )
                .toList();
      } else if (_statusFilter == 'Forwarded') {
        result =
            result
                .where((item) => item.status == 'Forwarded to Yayasan')
                .toList();
      } else if (_statusFilter == 'Rejected') {
        result = result.where((item) => item.status == 'Rejected').toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result =
          result
              .where(
                (item) =>
                    item.activityName.toLowerCase().contains(query) ||
                    item.paymentId.toLowerCase().contains(query) ||
                    item.activityId.toLowerCase().contains(query) ||
                    item.preacherName.toLowerCase().contains(query),
              )
              .toList();
    }

    _visible = result;
    notifyListeners();
  }

  Future<String> _generatePaymentId() async {
    final year = DateTime.now().year;
    final snapshot =
        await _db
            .collection('payment')
            .where('paymentId', isGreaterThanOrEqualTo: 'PAY-$year-')
            .where('paymentId', isLessThan: 'PAY-${year + 1}-')
            .orderBy('paymentId', descending: true)
            .limit(1)
            .get();

    int sequence = 1;
    if (snapshot.docs.isNotEmpty) {
      final lastPaymentId = snapshot.docs.first.data()['paymentId'] as String?;
      if (lastPaymentId != null) {
        final parts = lastPaymentId.split('-');
        if (parts.length == 3) {
          sequence = (int.tryParse(parts[2]) ?? 0) + 1;
        }
      }
    }

    return 'PAY-$year-${sequence.toString().padLeft(6, '0')}';
  }

  Future<void> forwardToYayasan(Payment payment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final paymentId = await _generatePaymentId();

      await _db.collection('payment').add({
        'paymentId': paymentId,
        'activityId': payment.activityId,
        'activityName': payment.activityName,
        'preacherId': payment.preacherId,
        'preacherName': payment.preacherName,
        'activityDate': Timestamp.fromDate(payment.activityDate),
        'amount': payment.amount,
        'paymentAmount': payment.amount,
        'status': 'Forwarded to Yayasan',
        'previousPaymentId': payment.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the original payment document status
      await _db.collection('payment').doc(payment.id).update({
        'status': 'Forwarded to Yayasan',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final activityQuery =
          await _db
              .collection('activities')
              .where('activityId', isEqualTo: payment.activityId)
              .limit(1)
              .get();

      if (activityQuery.docs.isNotEmpty) {
        final activityDoc = activityQuery.docs.first;
        await _db.collection('activities').doc(activityDoc.id).update({
          'status': 'Forwarded to Yayasan',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _isLoading = false;
      await loadPayments();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to forward payment: $error';
      notifyListeners();
    }
  }
}
