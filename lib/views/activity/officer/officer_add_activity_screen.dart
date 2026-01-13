import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/officer_activity_view_model.dart';
import '../widgets/map_location_picker.dart';

class OfficerAddActivityScreen extends StatelessWidget {
  const OfficerAddActivityScreen({super.key});

  static Widget withProvider() {
    return ChangeNotifierProvider(
      create: (_) => OfficerActivityViewModel(),
      child: const OfficerAddActivityScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _OfficerAddActivityContent();
  }
}

class _OfficerAddActivityContent extends StatefulWidget {
  const _OfficerAddActivityContent();

  @override
  State<_OfficerAddActivityContent> createState() => _OfficerAddActivityContentState();
}

class _OfficerAddActivityContentState extends State<_OfficerAddActivityContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _venueController = TextEditingController();
  final _topicController = TextEditingController();
  final _requirementsController = TextEditingController();

  String _activityType = 'Keynote Lecture';
  String _urgency = 'Normal';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

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
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _venueController.dispose();
    _topicController.dispose();
    _requirementsController.dispose();
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
          'Add Activity',
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
                _buildActivityTypeDropdown(),
                const SizedBox(height: 16),
                _buildUrgencyDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _titleController,
                  label: 'Expected Topic / Title *',
                  hint: 'Describe the main point of the topic',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildLocationPicker(context),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _venueController,
                  label: 'Venue *',
                  hint: 'e.g., Main Hall, Level 1',
                ),
                const SizedBox(height: 16),
                _buildDatePicker(context),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTimePicker(context, true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimePicker(context, false)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _topicController,
                  label: 'Topic *',
                  hint: 'Enter activity topic',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _requirementsController,
                  label: 'Special Requirements',
                  hint: 'e.g., A/V needs, specific audience',
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
                      elevation: 0,
                    ),
                    onPressed: viewModel.isLoading ? null : () => _handleSave(context, viewModel),
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
                            'Save Activity',
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

  Widget _buildActivityTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _activityType,
      decoration: InputDecoration(
        labelText: 'Activity Type *',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
      ),
      items: _activityTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _activityType = value);
        }
      },
    );
  }

  Widget _buildUrgencyDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _urgency,
        decoration: InputDecoration(
          labelText: 'Urgency Level *',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0066FF)),
          ),
        ),
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
          setState(() {
            _urgency = value!;
          });
        },
      ),
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return InkWell(
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
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Target Location *',
            hintText: 'Tap to select from map',
            suffixIcon: const Icon(Icons.map),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0066FF)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a location';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
      ),
      validator: (value) {
        if (label.contains('*') && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date *',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0066FF)),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_selectedDate),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, bool isStartTime) {
    final time = isStartTime ? _startTime : _endTime;
    final label = isStartTime ? 'Start Time *' : 'End Time *';

    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selectedTime != null) {
          setState(() {
            if (isStartTime) {
              _startTime = selectedTime;
            } else {
              _endTime = selectedTime;
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0066FF)),
          ),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(time.format(context)),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, OfficerActivityViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    final success = await viewModel.createActivity(
      activityType: _activityType,
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      venue: _venueController.text.trim(),
      activityDate: _selectedDate,
      startTime: startTimeStr,
      endTime: endTimeStr,
      topic: _topicController.text.trim(),
      specialRequirements: _requirementsController.text.trim(),
      urgency: _urgency,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity created successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to create activity'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
