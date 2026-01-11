// Domain Model: SavedReport
// Component Name for SDD: SavedReport
// Package: com.muip.psm.domain

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a saved/generated report in the system
/// Stores report metadata and location
class SavedReport {
  final String? id; // Document ID
  final String generatedBy; // User ID of Officer who generated
  final String reportType; // 'KPI', 'Activity', 'Payment'
  final Map<String, dynamic>? filtersUsed; // Snapshot of filters applied
  final String filePath; // Path to stored PDF/Excel file
  final DateTime? generatedAt;
  
  SavedReport({
    this.id,
    required this.generatedBy,
    required this.reportType,
    this.filtersUsed,
    required this.filePath,
    this.generatedAt,
  });
  
  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'generated_by': generatedBy,
      'report_type': reportType,
      'filters_used': filtersUsed ?? {},
      'file_path': filePath,
      'generated_at': generatedAt != null 
          ? Timestamp.fromDate(generatedAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
  
  // Create from Firestore document
  factory SavedReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavedReport(
      id: doc.id,
      generatedBy: data['generated_by'] ?? '',
      reportType: data['report_type'] ?? '',
      filtersUsed: data['filters_used'] != null 
          ? Map<String, dynamic>.from(data['filters_used']) 
          : null,
      filePath: data['file_path'] ?? '',
      generatedAt: data['generated_at'] != null 
          ? (data['generated_at'] as Timestamp).toDate() 
          : null,
    );
  }
  
  // Create from Map
  factory SavedReport.fromMap(Map<String, dynamic> map) {
    return SavedReport(
      id: map['id']?.toString(),
      generatedBy: map['generated_by']?.toString() ?? '',
      reportType: map['report_type'] ?? '',
      filtersUsed: map['filters_used'] != null 
          ? Map<String, dynamic>.from(map['filters_used']) 
          : null,
      filePath: map['file_path'] ?? '',
      generatedAt: map['generated_at'] != null 
          ? DateTime.parse(map['generated_at']) 
          : null,
    );
  }
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'generated_by': generatedBy,
      'report_type': reportType,
      'filters_used': filtersUsed,
      'file_path': filePath,
      'generated_at': generatedAt?.toIso8601String(),
    };
  }
  
  // Copy with
  SavedReport copyWith({
    String? id,
    String? generatedBy,
    String? reportType,
    Map<String, dynamic>? filtersUsed,
    String? filePath,
    DateTime? generatedAt,
  }) {
    return SavedReport(
      id: id ?? this.id,
      generatedBy: generatedBy ?? this.generatedBy,
      reportType: reportType ?? this.reportType,
      filtersUsed: filtersUsed ?? this.filtersUsed,
      filePath: filePath ?? this.filePath,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
  
  @override
  String toString() {
    return 'SavedReport(id: $id, type: $reportType, generatedAt: $generatedAt)';
  }
}
