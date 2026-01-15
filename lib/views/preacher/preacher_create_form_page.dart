import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/preacher.dart';
import '../../viewmodels/preacher_controller.dart';

class PreacherCreateFormPage extends StatefulWidget {
  const PreacherCreateFormPage({super.key});

  static Widget withProvider() {
    return ChangeNotifierProvider(
      create: (_) => PreacherController(),
      child: const PreacherCreateFormPage(),
    );
  }

  @override
  State<PreacherCreateFormPage> createState() => _PreacherCreateFormPageState();
}

class _PreacherCreateFormPageState extends State<PreacherCreateFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _regionCtrl.dispose();
    _specializationCtrl.dispose();
    _skillsCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<PreacherController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Preacher'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(controller),
            child:
                _saving
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              validator:
                  (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            _buildTextField(
              controller: _emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final ok = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                ).hasMatch(v.trim());
                return ok ? null : 'Invalid email';
              },
            ),
            _buildTextField(
              controller: _phoneCtrl,
              label: 'Phone',
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: _regionCtrl,
              label: 'Region',
              validator:
                  (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            _buildTextField(
              controller: _specializationCtrl,
              label: 'Specialization (comma separated)',
              validator:
                  (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            _buildTextField(
              controller: _skillsCtrl,
              label: 'Skills (comma separated)',
              validator:
                  (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            _buildTextField(controller: _bioCtrl, label: 'Bio', maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _save(PreacherController controller) async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or Missing Information')),
      );
      return;
    }
    setState(() => _saving = true);

    final data = <String, dynamic>{
      'fullName': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'region': _regionCtrl.text.trim(),
      'specialization':
          _specializationCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      'skills':
          _skillsCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      'bio': _bioCtrl.text.trim(),
    };

    try {
      await controller.createPreacher(data);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preacher Profile Updated')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
