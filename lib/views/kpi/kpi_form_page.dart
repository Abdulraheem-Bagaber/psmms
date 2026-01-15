import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/kpi_controller.dart';
import '../../models/preacher.dart';

/// MUIP Official view: Form to set/edit KPI targets for a preacher
class KPIFormPage extends StatefulWidget {
  final Preacher preacher;

  const KPIFormPage({super.key, required this.preacher});

  @override
  State<KPIFormPage> createState() => _KPIFormPageState();
}

class _KPIFormPageState extends State<KPIFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _monthlySessionController =
      TextEditingController();
  final TextEditingController _totalAttendanceController =
      TextEditingController();
  final TextEditingController _newConvertsController = TextEditingController();
  final TextEditingController _baptismsController = TextEditingController();
  final TextEditingController _communityProjectsController =
      TextEditingController();
  final TextEditingController _charityEventsController =
      TextEditingController();
  final TextEditingController _youthProgramController = TextEditingController();

  // Date range
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    // Set default date range (from today to end of month)
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month + 1, 0);

    // Load existing KPI after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingKPI();
    });
  }

  Future<void> _loadExistingKPI() async {
    final controller = context.read<KPIController>();

    await controller.loadKPI(
      widget.preacher.preacherId,
      _startDate!,
      _endDate!,
    );

    // If KPI exists, populate form (Edit mode)
    if (controller.currentKPI != null) {
      final kpi = controller.currentKPI!;
      setState(() {
        _isEditMode = true;
        _monthlySessionController.text = kpi.monthlySessionTarget.toString();
        _totalAttendanceController.text = kpi.totalAttendanceTarget.toString();
        _newConvertsController.text = kpi.newConvertsTarget.toString();
        _baptismsController.text = kpi.baptismsTarget.toString();
        _communityProjectsController.text =
            kpi.communityProjectsTarget.toString();
        _charityEventsController.text = kpi.charityEventsTarget.toString();
        _youthProgramController.text =
            kpi.youthProgramAttendanceTarget.toString();
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

  // Save KPI targets
  Future<void> _saveTargets() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('Please fill in all required fields');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showErrorDialog('Please select performance period');
      return;
    }

    // Validate that fields are not empty
    if (_monthlySessionController.text.isEmpty ||
        _totalAttendanceController.text.isEmpty) {
      _showErrorDialog('Monthly Sermons and Total Attendance are required');
      return;
    }

    final controller = context.read<KPIController>();

    final success = await controller.saveKPITargets(
      preacherId: widget.preacher.preacherId,
      monthlySessionTarget: int.tryParse(_monthlySessionController.text) ?? 0,
      totalAttendanceTarget: int.tryParse(_totalAttendanceController.text) ?? 0,
      newConvertsTarget: int.tryParse(_newConvertsController.text) ?? 0,
      baptismsTarget: int.tryParse(_baptismsController.text) ?? 0,
      communityProjectsTarget: int.tryParse(_communityProjectsController.text) ?? 0,
      charityEventsTarget: int.tryParse(_charityEventsController.text) ?? 0,
      youthProgramAttendanceTarget: int.tryParse(_youthProgramController.text) ?? 0,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    if (success && mounted) {
      _showSuccessDialog(controller.successMessage!);
    } else if (controller.error != null && mounted) {
      _showErrorDialog(controller.error!);
    }
  }

  void _showSuccessDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Navigate back after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          _startDate != null && _endDate != null
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit KPI Targets' : 'Set KPI Targets',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preacher Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF3B82F6),
                        child: Text(
                          widget.preacher.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.preacher.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${widget.preacher.preacherId}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Performance Period
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance Period',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectDateRange,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _startDate != null && _endDate != null
                                      ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                                      : 'Select Date Range',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // KPI Metrics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KPI Targets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Monthly Sermons Delivered',
                        hint: 'e.g., 20',
                        controller: _monthlySessionController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Total Attendance',
                        hint: 'e.g., 500',
                        controller: _totalAttendanceController,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: Consumer<KPIController>(
                    builder: (context, controller, _) {
                      return ElevatedButton(
                        onPressed: controller.isLoading ? null : _saveTargets,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          disabledBackgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Update Targets' : 'Save Targets',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            final intValue = int.tryParse(value);
            if (intValue == null || intValue <= 0) {
              return 'Please enter a positive number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
