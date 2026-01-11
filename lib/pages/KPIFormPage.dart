// Page: Edit KPI (Manage KPI)
// Component Name for SDD: Edit_KPI_Page.dart
// Package: com.muip.psm.pages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/kpi_controller.dart';
import '../models/User.dart';

/// MUIP Official view: Form to set/edit KPI targets for a preacher
/// Corresponds to Basic Flow Steps 4-8 and Alternative Flow [A1]
class ManageKPIPage extends StatefulWidget {
  final Preacher preacher;

  const ManageKPIPage({
    super.key,
    required this.preacher,
  });

  @override
  State<ManageKPIPage> createState() => _ManageKPIPageState();
}

class _ManageKPIPageState extends State<ManageKPIPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _monthlySessionController = TextEditingController();
  final TextEditingController _totalAttendanceController = TextEditingController();
  final TextEditingController _newConvertsController = TextEditingController();
  final TextEditingController _baptismsController = TextEditingController();
  final TextEditingController _communityProjectsController = TextEditingController();
  final TextEditingController _charityEventsController = TextEditingController();
  final TextEditingController _youthProgramController = TextEditingController();
  
  // Date range
  DateTime? _startDate;
  DateTime? _endDate;
  
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    
    // Set default date range (current month)
    _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    
    // Load existing KPI after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingKPI();
    });
  }

  Future<void> _loadExistingKPI() async {
    final controller = context.read<KPIController>();
    
    await controller.loadKPI(widget.preacher.id!, _startDate!, _endDate!);
    
    // If KPI exists, populate form (Edit mode - Alternative Flow [A1])
    if (controller.currentKPI != null) {
      setState(() {
        _isEditMode = true;
        final kpi = controller.currentKPI!;
        _monthlySessionController.text = kpi.monthlySessionTarget.toString();
        _totalAttendanceController.text = kpi.totalAttendanceTarget.toString();
        _newConvertsController.text = kpi.newConvertsTarget.toString();
        _baptismsController.text = kpi.baptismsTarget.toString();
        _communityProjectsController.text = kpi.communityProjectsTarget.toString();
        _charityEventsController.text = kpi.charityEventsTarget.toString();
        _youthProgramController.text = kpi.youthProgramAttendanceTarget.toString();
        _startDate = kpi.startDate;
        _endDate = kpi.endDate;
      });
    }
  }

  @override
  void dispose() {
    _monthlySessionController.dispose();
    _totalAttendanceController.dispose();
    _newConvertsController.dispose();
    _baptismsController.dispose();
    _communityProjectsController.dispose();
    _charityEventsController.dispose();
    _youthProgramController.dispose();
    super.dispose();
  }

  // Save KPI targets (Basic Flow Step 6)
  Future<void> _saveTargets() async {
    // Validate form (Exception Flow [E1])
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showErrorDialog('Please select performance period');
      return;
    }

    final controller = context.read<KPIController>();
    
    final success = await controller.saveKPITargets(
      preacherId: widget.preacher.id!,
      monthlySessionTarget: int.parse(_monthlySessionController.text),
      totalAttendanceTarget: int.parse(_totalAttendanceController.text),
      newConvertsTarget: int.parse(_newConvertsController.text),
      baptismsTarget: int.parse(_baptismsController.text),
      communityProjectsTarget: int.parse(_communityProjectsController.text),
      charityEventsTarget: int.parse(_charityEventsController.text),
      youthProgramAttendanceTarget: int.parse(_youthProgramController.text),
      startDate: _startDate!,
      endDate: _endDate!,
    );

    if (success && mounted) {
      // Show success message (Basic Flow Step 8 / Alternative Flow Step 6)
      _showSuccessDialog(controller.successMessage!);
    } else if (controller.error != null && mounted) {
      _showErrorDialog(controller.error!);
    }
  }

  void _showSuccessDialog(String message) {
    // Show a success banner at the top
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Navigate back after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Return to preacher list
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit KPI',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<KPIController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preacher Name Header
                  Text(
                    'Targets for: ${widget.preacher.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Number of sermons
                  _buildTextField(
                    label: 'Number of sermons',
                    hint: 'Enter number',
                    controller: _monthlySessionController,
                  ),
                  const SizedBox(height: 16),

                  // Number of attendees
                  _buildTextField(
                    label: 'Number of attendees',
                    hint: 'Enter number',
                    controller: _totalAttendanceController,
                  ),
                  const SizedBox(height: 16),

                  // Number of new converts
                  _buildTextField(
                    label: 'Number of new converts',
                    hint: 'Enter number',
                    controller: _newConvertsController,
                  ),
                  const SizedBox(height: 16),

                  // Number of baptisms
                  _buildTextField(
                    label: 'Number of baptisms',
                    hint: 'Enter number',
                    controller: _baptismsController,
                  ),
                  const SizedBox(height: 16),

                  // Number of community projects
                  _buildTextField(
                    label: 'Number of community projects',
                    hint: 'Enter number',
                    controller: _communityProjectsController,
                  ),
                  const SizedBox(height: 16),

                  // Charity Events
                  _buildTextField(
                    label: 'Charity Events Organized',
                    hint: 'Enter number',
                    controller: _charityEventsController,
                  ),
                  const SizedBox(height: 16),

                  // Youth Program
                  _buildTextField(
                    label: 'Youth Program Attendance',
                    hint: 'Enter number',
                    controller: _youthProgramController,
                  ),
                  const SizedBox(height: 24),

                  // Performance Period
                  const Text(
                    'Performance Period',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          label: 'Start Date',
                          date: _startDate,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker(
                          label: 'End Date',
                          date: _endDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Save/Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveTargets,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditMode ? 'Update Targets' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            final number = int.tryParse(value);
            if (number == null) {
              return 'Must be a number';
            }
            if (number <= 0) {
              return 'Must be positive';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select date',
                  style: TextStyle(
                    color: date != null ? Colors.black87 : Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
