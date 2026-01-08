import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report.dart';
import '../../viewmodels/report_controller.dart';

class ReportingDashboardScreen extends StatelessWidget {
  const ReportingDashboardScreen({super.key});

  static Widget withProvider() {
    return ChangeNotifierProvider(
      create: (_) => ReportController()..generateReport(),
      child: const ReportingDashboardScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(controller),
          _buildFilters(context, controller),
          Expanded(child: _buildContent(context, controller)),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ReportController controller) {
    final categories = [
      {
        'label': 'Activity',
        'value': ReportCategory.activity,
        'icon': Icons.event,
      },
      {
        'label': 'Payment',
        'value': ReportCategory.payment,
        'icon': Icons.payments,
      },
      {'label': 'KPI', 'value': ReportCategory.kpi, 'icon': Icons.analytics},
      {
        'label': 'Coverage',
        'value': ReportCategory.coverage,
        'icon': Icons.map,
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children:
            categories.map((cat) {
              final isSelected = controller.category == cat['value'];
              return Expanded(
                child: GestureDetector(
                  onTap:
                      () => controller.onCategoryChanged(
                        cat['value'] as ReportCategory,
                      ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF0066FF)
                              : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 20,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ReportController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDateRange(context, controller),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${DateFormat('dd/MM/yy').format(controller.dateStart)} - ${DateFormat('dd/MM/yy').format(controller.dateEnd)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.region,
                  items:
                      const ['All', 'North', 'Central', 'South', 'East', 'West']
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) controller.onRegionChanged(val);
                  },
                  decoration: InputDecoration(
                    labelText: 'Region',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  controller.isLoading ? null : controller.generateReport,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Generate Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReportController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(controller.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.generateReport,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final report = controller.currentReport;
    if (report == null) {
      return const Center(child: Text('No report generated yet.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(report),
          const SizedBox(height: 16),
          _buildDetailTable(report),
          const SizedBox(height: 16),
          _buildExportButtons(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Report report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (report.activitySummary != null)
            _buildActivitySummary(report.activitySummary!),
          if (report.paymentSummary != null)
            _buildPaymentSummary(report.paymentSummary!),
          if (report.kpiSummary != null) _buildKPISummary(report.kpiSummary!),
          if (report.coverageSummary != null)
            _buildCoverageSummary(report.coverageSummary!),
        ],
      ),
    );
  }

  Widget _buildActivitySummary(ActivitySummary summary) {
    return Column(
      children: [
        _summaryRow(
          'Total Activities',
          summary.totalCount.toString(),
          Colors.blue,
        ),
        _summaryRow(
          'Available',
          summary.availableCount.toString(),
          Colors.cyan,
        ),
        _summaryRow('Assigned', summary.assignedCount.toString(), Colors.amber),
        _summaryRow(
          'Submitted',
          summary.submittedCount.toString(),
          Colors.orange,
        ),
        _summaryRow('Approved', summary.approvedCount.toString(), Colors.green),
        _summaryRow('Rejected', summary.rejectedCount.toString(), Colors.red),
        const Divider(height: 24),
        _summaryRow(
          'Approval Rate',
          '${summary.approvalRate.toStringAsFixed(1)}%',
          Colors.teal,
        ),
        _summaryRow(
          'Rejection Rate',
          '${summary.rejectionRate.toStringAsFixed(1)}%',
          Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(PaymentSummary summary) {
    return Column(
      children: [
        _summaryRow(
          'Total Amount',
          'RM ${summary.totalAmount.toStringAsFixed(2)}',
          Colors.blue,
        ),
        _summaryRow(
          'Pending',
          'RM ${summary.pendingAmount.toStringAsFixed(2)}',
          Colors.amber,
        ),
        _summaryRow(
          'Approved',
          'RM ${summary.approvedAmount.toStringAsFixed(2)}',
          Colors.green,
        ),
        _summaryRow(
          'Forwarded',
          'RM ${summary.forwardedAmount.toStringAsFixed(2)}',
          Colors.cyan,
        ),
        _summaryRow(
          'Paid',
          'RM ${summary.paidAmount.toStringAsFixed(2)}',
          Colors.teal,
        ),
        _summaryRow(
          'Rejected',
          'RM ${summary.rejectedAmount.toStringAsFixed(2)}',
          Colors.red,
        ),
        const Divider(height: 24),
        _summaryRow(
          'Transactions',
          summary.transactionCount.toString(),
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildKPISummary(KPISummary summary) {
    return Column(
      children: [
        _summaryRow(
          'Avg Approval Rate',
          '${summary.avgApprovalRate.toStringAsFixed(1)}%',
          Colors.green,
        ),
        _summaryRow(
          'Activities Completed',
          summary.totalActivitiesCompleted.toStringAsFixed(0),
          Colors.blue,
        ),
        _summaryRow(
          'Avg Payment/Activity',
          'RM ${summary.avgPaymentPerActivity.toStringAsFixed(2)}',
          Colors.teal,
        ),
        _summaryRow(
          'Unique Preachers',
          summary.uniquePreachers.toString(),
          Colors.purple,
        ),
        _summaryRow(
          'Coverage Score',
          '${summary.coverageScore.toStringAsFixed(1)}%',
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildCoverageSummary(CoverageSummary summary) {
    return Column(
      children: [
        _summaryRow(
          'Regions Covered',
          summary.coveredRegions.length.toString(),
          Colors.blue,
        ),
        _summaryRow(
          'Coverage %',
          '${summary.regionCoveragePercentage.toStringAsFixed(1)}%',
          Colors.green,
        ),
        const Divider(height: 24),
        ...summary.activitiesByRegion.entries.map(
          (e) =>
              _summaryRow(e.key, '${e.value} activities', Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTable(Report report) {
    if (report.detailRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...report.detailRows.take(10).map((row) => _detailRow(row)),
          if (report.detailRows.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${report.detailRows.length - 10} more rows',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(Map<String, dynamic> row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            row.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.key}:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDetailValue(entry.value),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildExportButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showExportDialog(context, 'PDF'),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showExportDialog(context, 'Excel'),
            icon: const Icon(Icons.table_chart),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showExportDialog(context, 'CSV'),
            icon: const Icon(Icons.description),
            label: const Text('CSV'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    ReportController controller,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.dateStart,
        end: controller.dateEnd,
      ),
    );
    if (picked != null) {
      controller.onDateRangeChanged(picked.start, picked.end);
    }
  }

  Future<void> _showExportDialog(BuildContext context, String format) async {
    final controller = Provider.of<ReportController>(context, listen: false);

    if (controller.currentReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate a report first')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Exporting...'),
              ],
            ),
          ),
    );

    try {
      if (format == 'PDF') {
        await controller.exportToPDF();
      } else if (format == 'CSV' || format == 'Excel') {
        await controller.exportToCSV();
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (controller.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$format exported successfully')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(controller.error!)));
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  String _formatDetailValue(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy, HH:mm').format(value.toDate());
    }
    return value.toString();
  }
}
