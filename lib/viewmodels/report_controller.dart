import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/report.dart';
import '../services/report_api_handler.dart';

class ReportController extends ChangeNotifier {
  ReportController({ReportAPIHandler? apiHandler, FirebaseFirestore? firestore})
    : _api = apiHandler ?? ReportAPIHandler(firestore: firestore);

  final ReportAPIHandler _api;

  ReportCategory _category = ReportCategory.activity;
  DateTime _dateStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateEnd = DateTime.now();
  String _region = 'All';
  String? _preacherId;

  Report? _currentReport;
  bool _isLoading = false;
  String? _error;

  ReportCategory get category => _category;
  DateTime get dateStart => _dateStart;
  DateTime get dateEnd => _dateEnd;
  String get region => _region;
  String? get preacherId => _preacherId;
  Report? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void onCategoryChanged(ReportCategory newCategory) {
    _category = newCategory;
    notifyListeners();
    generateReport();
  }

  void onDateRangeChanged(DateTime start, DateTime end) {
    _dateStart = start;
    _dateEnd = end;
    notifyListeners();
  }

  void onRegionChanged(String newRegion) {
    _region = newRegion;
    notifyListeners();
  }

  void onPreacherIdChanged(String? id) {
    _preacherId = id;
    notifyListeners();
  }

  Future<void> generateReport() async {
    _isLoading = true;
    _error = null;
    _currentReport = null;
    notifyListeners();

    try {
      final regionFilter = _region == 'All' ? null : _region;
      Report report;

      switch (_category) {
        case ReportCategory.activity:
          report = await _api.generateActivityReport(
            dateStart: _dateStart,
            dateEnd: _dateEnd,
            region: regionFilter,
            preacherId: _preacherId,
          );
          break;
        case ReportCategory.payment:
          report = await _api.generatePaymentReport(
            dateStart: _dateStart,
            dateEnd: _dateEnd,
            region: regionFilter,
            preacherId: _preacherId,
          );
          break;
        case ReportCategory.kpi:
          report = await _api.generateKPIReport(
            dateStart: _dateStart,
            dateEnd: _dateEnd,
            region: regionFilter,
          );
          break;
        case ReportCategory.coverage:
          report = await _api.generateCoverageReport(
            dateStart: _dateStart,
            dateEnd: _dateEnd,
          );
          break;
      }

      _currentReport = report;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to generate report: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> exportToPDF() async {
    if (_currentReport == null) return;

    try {
      final pdf = pw.Document();
      final report = _currentReport!;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${_getCategoryName(report.category)} Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Period: ${DateFormat('dd MMM yyyy').format(report.dateStart)} - ${DateFormat('dd MMM yyyy').format(report.dateEnd)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                if (report.region != null)
                  pw.Text(
                    'Region: ${report.region}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                ..._buildPDFSummary(report),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                ..._buildPDFDetails(report),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      _error = 'Failed to export PDF: $e';
      notifyListeners();
    }
  }

  Future<void> exportToCSV() async {
    if (_currentReport == null) return;

    try {
      final report = _currentReport!;
      List<List<dynamic>> rows = [];

      // Header
      rows.add(['${_getCategoryName(report.category)} Report']);
      rows.add([
        'Period',
        '${DateFormat('dd MMM yyyy').format(report.dateStart)} - ${DateFormat('dd MMM yyyy').format(report.dateEnd)}',
      ]);
      if (report.region != null) rows.add(['Region', report.region]);
      rows.add([]);
      rows.add(['Summary']);

      // Summary data
      rows.addAll(_buildCSVSummary(report));
      rows.add([]);
      rows.add(['Details']);

      // Detail rows
      if (report.detailRows.isNotEmpty) {
        final headers = report.detailRows.first.keys.toList();
        rows.add(headers);
        for (final row in report.detailRows) {
          rows.add(headers.map((key) => _formatCSVValue(row[key])).toList());
        }
      }

      final csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'report_${report.category.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to export CSV: $e';
      notifyListeners();
    }
  }

  List<pw.Widget> _buildPDFSummary(Report report) {
    final widgets = <pw.Widget>[];

    if (report.activitySummary != null) {
      final s = report.activitySummary!;
      widgets.addAll([
        _pdfRow('Total Activities', s.totalCount.toString()),
        _pdfRow('Available', s.availableCount.toString()),
        _pdfRow('Approved', s.approvedCount.toString()),
        _pdfRow('Rejected', s.rejectedCount.toString()),
        _pdfRow('Approval Rate', '${s.approvalRate.toStringAsFixed(1)}%'),
      ]);
    }

    if (report.paymentSummary != null) {
      final s = report.paymentSummary!;
      widgets.addAll([
        _pdfRow('Total Amount', 'RM ${s.totalAmount.toStringAsFixed(2)}'),
        _pdfRow('Pending', 'RM ${s.pendingAmount.toStringAsFixed(2)}'),
        _pdfRow('Approved', 'RM ${s.approvedAmount.toStringAsFixed(2)}'),
        _pdfRow('Paid', 'RM ${s.paidAmount.toStringAsFixed(2)}'),
        _pdfRow('Transactions', s.transactionCount.toString()),
      ]);
    }

    if (report.kpiSummary != null) {
      final s = report.kpiSummary!;
      widgets.addAll([
        _pdfRow(
          'Avg Approval Rate',
          '${s.avgApprovalRate.toStringAsFixed(1)}%',
        ),
        _pdfRow(
          'Activities Completed',
          s.totalActivitiesCompleted.toStringAsFixed(0),
        ),
        _pdfRow(
          'Avg Payment/Activity',
          'RM ${s.avgPaymentPerActivity.toStringAsFixed(2)}',
        ),
        _pdfRow('Unique Preachers', s.uniquePreachers.toString()),
      ]);
    }

    if (report.coverageSummary != null) {
      final s = report.coverageSummary!;
      widgets.addAll([
        _pdfRow('Regions Covered', s.coveredRegions.length.toString()),
        _pdfRow(
          'Coverage %',
          '${s.regionCoveragePercentage.toStringAsFixed(1)}%',
        ),
      ]);
    }

    return widgets;
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildPDFDetails(Report report) {
    final widgets = <pw.Widget>[];
    final rows = report.detailRows.take(20).toList();

    for (final row in rows) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:
                row.entries
                    .map(
                      (e) => pw.Text(
                        '${e.key}: ${_formatPDFValue(e.value)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    }

    if (report.detailRows.length > 20) {
      widgets.add(
        pw.Text(
          '+ ${report.detailRows.length - 20} more rows',
          style: const pw.TextStyle(fontSize: 10),
        ),
      );
    }

    return widgets;
  }

  List<List<dynamic>> _buildCSVSummary(Report report) {
    final rows = <List<dynamic>>[];

    if (report.activitySummary != null) {
      final s = report.activitySummary!;
      rows.addAll([
        ['Total Activities', s.totalCount],
        ['Available', s.availableCount],
        ['Approved', s.approvedCount],
        ['Rejected', s.rejectedCount],
        ['Approval Rate', '${s.approvalRate.toStringAsFixed(1)}%'],
      ]);
    }

    if (report.paymentSummary != null) {
      final s = report.paymentSummary!;
      rows.addAll([
        ['Total Amount', 'RM ${s.totalAmount.toStringAsFixed(2)}'],
        ['Pending', 'RM ${s.pendingAmount.toStringAsFixed(2)}'],
        ['Approved', 'RM ${s.approvedAmount.toStringAsFixed(2)}'],
        ['Paid', 'RM ${s.paidAmount.toStringAsFixed(2)}'],
        ['Transactions', s.transactionCount],
      ]);
    }

    if (report.kpiSummary != null) {
      final s = report.kpiSummary!;
      rows.addAll([
        ['Avg Approval Rate', '${s.avgApprovalRate.toStringAsFixed(1)}%'],
        ['Activities Completed', s.totalActivitiesCompleted.toStringAsFixed(0)],
        [
          'Avg Payment/Activity',
          'RM ${s.avgPaymentPerActivity.toStringAsFixed(2)}',
        ],
        ['Unique Preachers', s.uniquePreachers],
      ]);
    }

    if (report.coverageSummary != null) {
      final s = report.coverageSummary!;
      rows.addAll([
        ['Regions Covered', s.coveredRegions.length],
        ['Coverage %', '${s.regionCoveragePercentage.toStringAsFixed(1)}%'],
      ]);
    }

    return rows;
  }

  String _formatPDFValue(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy, HH:mm').format(value.toDate());
    }
    return value.toString();
  }

  String _formatCSVValue(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy, HH:mm').format(value.toDate());
    }
    return value.toString();
  }

  String _getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.activity:
        return 'Activity';
      case ReportCategory.payment:
        return 'Payment';
      case ReportCategory.kpi:
        return 'KPI';
      case ReportCategory.coverage:
        return 'Coverage';
    }
  }
}
