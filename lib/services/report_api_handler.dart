import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportAPIHandler {
  ReportAPIHandler({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<Report> generateActivityReport({
    required DateTime dateStart,
    required DateTime dateEnd,
    String? region,
    String? preacherId,
  }) async {
    Query query = _db
        .collection('activities')
        .where(
          'activityDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateStart),
        )
        .where(
          'activityDate',
          isLessThanOrEqualTo: Timestamp.fromDate(dateEnd),
        );

    if (region != null && region.isNotEmpty) {
      query = query.where('location', isEqualTo: region);
    }

    if (preacherId != null && preacherId.isNotEmpty) {
      query = query.where('assignedPreacherId', isEqualTo: preacherId);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    int totalCount = docs.length;
    int availableCount = 0;
    int assignedCount = 0;
    int submittedCount = 0;
    int approvedCount = 0;
    int rejectedCount = 0;

    final detailRows = <Map<String, dynamic>>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';

      if (status == 'Available') availableCount++;
      if (status == 'Assigned') assignedCount++;
      if (status == 'Submitted') submittedCount++;
      if (status == 'Approved') approvedCount++;
      if (status == 'Rejected') rejectedCount++;

      detailRows.add({
        'activityId': data['activityId'] ?? '',
        'title': data['title'] ?? '',
        'status': status,
        'location': data['location'] ?? '',
        'activityDate': data['activityDate'],
        'preacherName': data['assignedPreacherName'] ?? 'Unassigned',
      });
    }

    final summary = ActivitySummary(
      totalCount: totalCount,
      availableCount: availableCount,
      assignedCount: assignedCount,
      submittedCount: submittedCount,
      approvedCount: approvedCount,
      rejectedCount: rejectedCount,
    );

    return Report(
      category: ReportCategory.activity,
      dateStart: dateStart,
      dateEnd: dateEnd,
      region: region,
      preacherId: preacherId,
      generatedAt: DateTime.now(),
      activitySummary: summary,
      detailRows: detailRows,
    );
  }

  Future<Report> generatePaymentReport({
    required DateTime dateStart,
    required DateTime dateEnd,
    String? region,
    String? preacherId,
  }) async {
    Query query = _db.collection('payment');

    if (preacherId != null && preacherId.isNotEmpty) {
      query = query.where('preacherId', isEqualTo: preacherId);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    double totalAmount = 0;
    double pendingAmount = 0;
    double approvedAmount = 0;
    double forwardedAmount = 0;
    double paidAmount = 0;
    double rejectedAmount = 0;

    final detailRows = <Map<String, dynamic>>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';
      final amount =
          ((data['amount'] ?? data['paymentAmount']) ?? 0.0).toDouble();
      final activityDate = data['activityDate'];

      DateTime? pDate;
      if (activityDate is Timestamp) pDate = activityDate.toDate();
      if (activityDate is String) pDate = DateTime.tryParse(activityDate);

      if (pDate != null &&
          (pDate.isBefore(dateEnd) && pDate.isAfter(dateStart))) {
        if (region == null || region.isEmpty) {
          totalAmount += amount;

          if (status == 'Pending Payment') pendingAmount += amount;
          if (status == 'Approved by MUIP Officer') approvedAmount += amount;
          if (status == 'Forwarded to Yayasan') forwardedAmount += amount;
          if (status == 'Paid') paidAmount += amount;
          if (status == 'Rejected') rejectedAmount += amount;

          detailRows.add({
            'paymentId': data['paymentId'] ?? '',
            'preacherName': data['preacherName'] ?? '',
            'activityName': data['activityName'] ?? '',
            'amount': amount,
            'status': status,
            'activityDate': activityDate,
          });
        }
      }
    }

    final summary = PaymentSummary(
      totalAmount: totalAmount,
      pendingAmount: pendingAmount,
      approvedAmount: approvedAmount,
      forwardedAmount: forwardedAmount,
      paidAmount: paidAmount,
      rejectedAmount: rejectedAmount,
      transactionCount: detailRows.length,
    );

    return Report(
      category: ReportCategory.payment,
      dateStart: dateStart,
      dateEnd: dateEnd,
      region: region,
      preacherId: preacherId,
      generatedAt: DateTime.now(),
      paymentSummary: summary,
      detailRows: detailRows,
    );
  }

  Future<Report> generateKPIReport({
    required DateTime dateStart,
    required DateTime dateEnd,
    String? region,
  }) async {
    Query actQuery = _db
        .collection('activities')
        .where(
          'activityDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateStart),
        )
        .where(
          'activityDate',
          isLessThanOrEqualTo: Timestamp.fromDate(dateEnd),
        );

    if (region != null && region.isNotEmpty) {
      actQuery = actQuery.where('location', isEqualTo: region);
    }

    final actSnapshot = await actQuery.get();
    final actDocs = actSnapshot.docs;

    Set<String> uniquePreachers = {};
    int totalApproved = 0;
    int totalSubmitted = 0;
    double totalPayments = 0;
    int totalActivities = actDocs.length;

    for (final doc in actDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';
      if (status == 'Approved') totalApproved++;
      if (status == 'Submitted') totalSubmitted++;
      final preacherId = data['assignedPreacherId'];
      if (preacherId != null) uniquePreachers.add(preacherId);
    }

    final paySnapshot = await _db.collection('payment').get();
    for (final doc in paySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount =
          ((data['amount'] ?? data['paymentAmount']) ?? 0.0).toDouble();
      totalPayments += amount;
    }

    final avgApprovalRate =
        totalSubmitted == 0 ? 0.0 : (totalApproved / totalSubmitted) * 100;
    final avgPaymentPerActivity =
        totalActivities == 0 ? 0.0 : totalPayments / totalActivities;

    final summary = KPISummary(
      avgApprovalRate: avgApprovalRate,
      totalActivitiesCompleted: totalActivities.toDouble(),
      avgPaymentPerActivity: avgPaymentPerActivity,
      uniquePreachers: uniquePreachers.length,
      coverageScore: 0, // To be computed from region distribution
    );

    return Report(
      category: ReportCategory.kpi,
      dateStart: dateStart,
      dateEnd: dateEnd,
      region: region,
      generatedAt: DateTime.now(),
      kpiSummary: summary,
      detailRows: [
        {'metric': 'Total Activities', 'value': totalActivities},
        {'metric': 'Approved', 'value': totalApproved},
        {
          'metric': 'Approval Rate',
          'value': '${avgApprovalRate.toStringAsFixed(2)}%',
        },
        {'metric': 'Unique Preachers', 'value': uniquePreachers.length},
        {
          'metric': 'Total Payments',
          'value': 'RM ${totalPayments.toStringAsFixed(2)}',
        },
        {
          'metric': 'Avg Payment/Activity',
          'value': 'RM ${avgPaymentPerActivity.toStringAsFixed(2)}',
        },
      ],
    );
  }

  Future<Report> generateCoverageReport({
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final actQuery = _db
        .collection('activities')
        .where(
          'activityDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateStart),
        )
        .where(
          'activityDate',
          isLessThanOrEqualTo: Timestamp.fromDate(dateEnd),
        );

    final snapshot = await actQuery.get();
    final docs = snapshot.docs;

    Map<String, int> activitiesByRegion = {};
    Map<String, Set<String>> preachersByRegion = {};
    Set<String> allRegions = {'North', 'Central', 'South', 'East', 'West'};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'] as String? ?? 'Unknown';
      final preacherId = data['assignedPreacherId'];

      activitiesByRegion[location] = (activitiesByRegion[location] ?? 0) + 1;

      if (preacherId != null) {
        preachersByRegion.putIfAbsent(location, () => {}).add(preacherId);
      }
    }

    final coveredRegions = activitiesByRegion.keys.toList();
    final regionCoveragePercentage =
        (coveredRegions.length / allRegions.length) * 100;

    final summary = CoverageSummary(
      activitiesByRegion: activitiesByRegion,
      preachersByRegion: preachersByRegion.map(
        (key, value) => MapEntry(key, value.length),
      ),
      coveredRegions: coveredRegions,
      regionCoveragePercentage: regionCoveragePercentage,
    );

    final detailRows =
        activitiesByRegion.entries
            .map(
              (e) => {
                'region': e.key,
                'activities': e.value,
                'preachers': preachersByRegion[e.key]?.length ?? 0,
              },
            )
            .toList();

    return Report(
      category: ReportCategory.coverage,
      dateStart: dateStart,
      dateEnd: dateEnd,
      generatedAt: DateTime.now(),
      coverageSummary: summary,
      detailRows: detailRows,
    );
  }
}
