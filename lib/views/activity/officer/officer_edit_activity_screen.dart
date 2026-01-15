import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/activity.dart';
import '../../../viewmodels/officer_activity_view_model.dart';
import '../widgets/map_location_picker.dart';

class OfficerEditActivityScreen extends StatelessWidget {
  final Activity activity;

  const OfficerEditActivityScreen({super.key, required this.activity});

  static Widget withProvider({required Activity activity}) {
    return ChangeNotifierProvider(
      create: (_) => OfficerActivityViewModel(),
      child: OfficerEditActivityScreen(activity: activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _OfficerEditActivityContent(activity: activity);
  }
}

class _OfficerEditActivityContent extends StatefulWidget {
  final Activity activity;

  const _OfficerEditActivityContent({required this.activity});

  @override
  State<_OfficerEditActivityContent> createState() => _OfficerEditActivityContentState();
}

class _OfficerEditActivityContentState extends State<_OfficerEditActivityContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _venueController;
  late TextEditingController _topicController;
  late TextEditingController _requirementsController;
  late TextEditingController _attendanceController;

  late String _activityType;
  late String _urgency;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  final List<String> _activityTypes = [
    'Keynote Lecture',
    'Community Service',
    'Workshop',
    'Seminar',
    'Religious Gathering',
  ];

  final List<String> _urgencyLevels = [
    'Normal',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity.title);
    _locationController = TextEditingController(text: widget.activity.location);
    _venueController = TextEditingController(text: widget.activity.venue);
    _topicController = TextEditingController(text: widget.activity.topic);
    _requirementsController = TextEditingController(text: widget.activity.specialRequirements);
    _attendanceController = TextEditingController(
      text: widget.activity.expectedAttendance?.toString() ?? '',
    );
    
    _activityType = widget.activity.activityType;
    _urgency = widget.activity.urgency;
    _selectedDate = widget.activity.activityDate;
    
    final startParts = widget.activity.startTime.split(':');
    _startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    
    final endParts = widget.activity.endTime.split(':');
    _endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _venueController.dispose();
    _topicController.dispose();
    _requirementsController.dispose();
    _attendanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OfficerActivityViewModel>();

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
          'Edit Activity',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
                DropdownButtonFormField<String>(
                  value: _activityType,
                  decoration: _inputDecoration('Activity Type'),
                  items: _activityTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _activityType = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _urgency,
                  decoration: _inputDecoration('Urgency Level'),
                  items: _urgencyLevels.map((urgency) {
                    return DropdownMenuItem(
                      value: urgency,
                      child: Row(
                        children: [
                          Icon(
                            urgency == 'Urgent' ? Icons.priority_high : Icons.low_priority,
                            color: urgency == 'Urgent' ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(urgency),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _urgency = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Expected Topic / Title'),
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapLocationPicker(
                          initialAddress: _locationController.text.isEmpty ? null : _locationController.text,
                        ),
                      ),
                    );

                    if (result != null && result['address'] != null) {
                      setState(() {
                        _locationController.text = result['address'];
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration('Location').copyWith(
                        suffixIcon: const Icon(Icons.map),
                        hintText: 'Tap to select from map',
                      ),
                      maxLines: 2,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _venueController,
                  decoration: _inputDecoration('Venue'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration('Date'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (time != null) setState(() => _startTime = time);
                        },
                        child: InputDecorator(
                          decoration: _inputDecoration('Start Time'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_startTime.format(context)),
                              const Icon(Icons.access_time, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (time != null) setState(() => _endTime = time);
                        },
                        child: InputDecorator(
                          decoration: _inputDecoration('End Time'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_endTime.format(context)),
                              const Icon(Icons.access_time, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _topicController,
                  decoration: _inputDecoration('Topic'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _attendanceController,
                  decoration: _inputDecoration('Expected Attendance').copyWith(
                    hintText: 'Number of expected attendees (for KPI tracking)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _requirementsController,
                  decoration: _inputDecoration('Special Requirements'),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: viewModel.isLoading ? null : () => _handleUpdate(context, viewModel),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update Activity',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0066FF)),
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context, OfficerActivityViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final expectedAttendance = int.tryParse(_attendanceController.text.trim());

    final success = await viewModel.updateActivity(
      widget.activity.id,
      activityType: _activityType,
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      venue: _venueController.text.trim(),
      activityDate: _selectedDate,
      startTime: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      endTime: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      topic: _topicController.text.trim(),
      specialRequirements: _requirementsController.text.trim(),
      urgency: _urgency,
      expectedAttendance: expectedAttendance,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Activity updated successfully' : viewModel.errorMessage ?? 'Update failed'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (success) Navigator.pop(context, true);
    }
  }
}
