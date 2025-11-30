import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String paymentId;
  final String activityId;
  final String activityName;
  final String preacherId;
  final String preacherName;
  final DateTime activityDate;
  final double amount;
  final String status;

  Payment({
    required this.id,
    required this.paymentId,
    required this.activityId,
    required this.activityName,
    required this.preacherId,
    required this.preacherName,
    required this.activityDate,
    required this.amount,
    required this.status,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime parsedDate;
    final dateField = data['activityDate'];
    if (dateField is Timestamp) {
      parsedDate = dateField.toDate();
    } else if (dateField is String) {
      parsedDate = DateTime.parse(dateField);
    } else {
      parsedDate = DateTime.now();
    }
    return Payment(
      id: doc.id,
      paymentId: data['paymentId'] ?? '',
      activityId: data['activityId'] ?? '',
      activityName: data['activityName'] ?? data['title'] ?? '',
      preacherId: data['preacherId'] ?? '',
      preacherName: data['preacherName'] ?? '',
      activityDate: parsedDate,
      amount: ((data['amount'] ?? data['paymentAmount']) ?? 0).toDouble(),
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'paymentId': paymentId,
      'activityId': activityId,
      'activityName': activityName,
      'preacherId': preacherId,
      'preacherName': preacherName,
      'activityDate': Timestamp.fromDate(activityDate),
      'amount': amount,
      'paymentAmount': amount,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
