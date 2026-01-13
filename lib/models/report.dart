enum ReportCategory { activity, payment, kpi, coverage }

class ActivitySummary {
  final int totalCount;
  final int availableCount;
  final int assignedCount;
  final int submittedCount;
  final int approvedCount;
  final int rejectedCount;

  const ActivitySummary({
    required this.totalCount,
    required this.availableCount,
    required this.assignedCount,
    required this.submittedCount,
    required this.approvedCount,
    required this.rejectedCount,
  });

  double get approvalRate =>
      submittedCount == 0 ? 0 : (approvedCount / submittedCount) * 100;
  double get rejectionRate =>
      submittedCount == 0 ? 0 : (rejectedCount / submittedCount) * 100;
}

class PaymentSummary {
  final double totalAmount;
  final double pendingAmount;
  final double approvedAmount;
  final double forwardedAmount;
  final double paidAmount;
  final double rejectedAmount;
  final int transactionCount;

  const PaymentSummary({
    required this.totalAmount,
    required this.pendingAmount,
    required this.approvedAmount,
    required this.forwardedAmount,
    required this.paidAmount,
    required this.rejectedAmount,
    required this.transactionCount,
  });
}

class KPISummary {
  final double avgApprovalRate;
  final double totalActivitiesCompleted;
  final double avgPaymentPerActivity;
  final int uniquePreachers;
  final double coverageScore; // percentage of regions covered

  const KPISummary({
    required this.avgApprovalRate,
    required this.totalActivitiesCompleted,
    required this.avgPaymentPerActivity,
    required this.uniquePreachers,
    required this.coverageScore,
  });
}

class CoverageSummary {
  final Map<String, int> activitiesByRegion;
  final Map<String, int> preachersByRegion;
  final List<String> coveredRegions;
  final double regionCoveragePercentage;

  const CoverageSummary({
    required this.activitiesByRegion,
    required this.preachersByRegion,
    required this.coveredRegions,
    required this.regionCoveragePercentage,
  });
}

class Report {
  final ReportCategory category;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String? region;
  final String? preacherId;
  final DateTime generatedAt;

  final ActivitySummary? activitySummary;
  final PaymentSummary? paymentSummary;
  final KPISummary? kpiSummary;
  final CoverageSummary? coverageSummary;

  final List<Map<String, dynamic>> detailRows;

  const Report({
    required this.category,
    required this.dateStart,
    required this.dateEnd,
    this.region,
    this.preacherId,
    required this.generatedAt,
    this.activitySummary,
    this.paymentSummary,
    this.kpiSummary,
    this.coverageSummary,
    required this.detailRows,
  });
}
