import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/payment.dart';

class PaymentFormViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Payment? sourceActivity;

  late final String activityId;
  late final String activityName;
  late final String preacherId;
  late final String preacherName;
  late final DateTime activityDate;
  late final double recommendedAmount;

  final TextEditingController paymentAmountController;
  final TextEditingController remarksController;

  String _paymentAmountText;
  String _remarksText;
  double paymentAmount;
  String? remarks;
  bool isSubmitting;
  String? successMessage;
  String? _errorMessage;
  bool _updatingPaymentAmount;
  bool _updatingRemarks;

  PaymentFormViewModel({Payment? initialActivity})
      : sourceActivity = initialActivity,
        activityId = initialActivity?.activityId ?? 'ACT-2024-00123',
        activityName = initialActivity?.activityName ?? 'Sample Activity',
        preacherId = initialActivity?.preacherId ?? 'PREACHER-001',
        preacherName = initialActivity?.preacherName ?? 'Johnathan Doe',
        activityDate = initialActivity?.activityDate ?? DateTime.now(),
        recommendedAmount = initialActivity?.amount ?? 300.00,
        paymentAmount = initialActivity?.amount ?? 300.00,
        paymentAmountController = TextEditingController(),
        remarksController = TextEditingController(),
        _paymentAmountText = (initialActivity?.amount ?? 300.00).toStringAsFixed(2),
        _remarksText = '',
        remarks = null,
        isSubmitting = false,
        successMessage = null,
        _errorMessage = null,
        _updatingPaymentAmount = false,
        _updatingRemarks = false {
    _setPaymentAmountText(_paymentAmountText);
    _setRemarksText(_remarksText);
  }

  String? get errorMessage => _errorMessage;
  String get recommendedAmountText => _formatCurrency(recommendedAmount);
  String get paymentAmountText => _paymentAmountText;
  String get remarksText => _remarksText;

  void onPaymentAmountChanged(String value) {
    if (_updatingPaymentAmount) return;
    _paymentAmountText = value;
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed != null) {
      paymentAmount = parsed;
    }
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void onRemarksChanged(String value) {
    if (_updatingRemarks) return;
    _remarksText = value;
    remarks = value.trim().isEmpty ? null : value;
  }

  Future<String> _generatePaymentId() async {
    final year = DateTime.now().year;
    final snapshot = await _db
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

  Future<void> submitForApproval() async {
    _errorMessage = null;
    successMessage = null;
    isSubmitting = true;
    notifyListeners();

    final parsed = double.tryParse(_paymentAmountText.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      isSubmitting = false;
      _errorMessage = 'Please enter a valid payment amount greater than 0.';
      notifyListeners();
      return;
    }

    if (sourceActivity == null) {
      isSubmitting = false;
      _errorMessage = 'No activity selected for payment.';
      notifyListeners();
      return;
    }

    paymentAmount = parsed;
    final trimmedRemarks = _remarksText.trim();
    remarks = trimmedRemarks.isEmpty ? null : trimmedRemarks;
    _setPaymentAmountText(parsed.toStringAsFixed(2));
    _setRemarksText(trimmedRemarks);

    try {
      final paymentId = await _generatePaymentId();
      final batch = _db.batch();

      final paymentRef = _db.collection('payment').doc();
      final payment = Payment(
        id: paymentRef.id,
        paymentId: paymentId,
        activityId: activityId,
        activityName: activityName,
        preacherId: preacherId,
        preacherName: preacherName,
        activityDate: activityDate,
        amount: paymentAmount,
        status: 'Approved by MUIP Officer',
      );

      final paymentData = payment.toFirestore();
      paymentData['remarks'] = remarks;
      batch.set(paymentRef, paymentData);

      final activityRef = _db.collection('activities').doc(sourceActivity!.id);
      batch.update(activityRef, {
        'status': 'Approved by MUIP Officer',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      isSubmitting = false;
      successMessage = 'Payment submitted for approval successfully.';
      notifyListeners();
    } catch (error) {
      isSubmitting = false;
      _errorMessage = 'Failed to submit payment: $error';
      notifyListeners();
    }
  }

  void clearSuccessMessage() {
    successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    paymentAmountController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  void _setPaymentAmountText(String value) {
    _paymentAmountText = value;
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed != null) {
      paymentAmount = parsed;
    }
    _updatingPaymentAmount = true;
    paymentAmountController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _updatingPaymentAmount = false;
  }

  void _setRemarksText(String value) {
    _remarksText = value;
    remarks = value.trim().isEmpty ? null : value;
    _updatingRemarks = true;
    remarksController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _updatingRemarks = false;
  }

  String _formatCurrency(double value) {
    return 'RM${value.toStringAsFixed(2)}';
  }
}
