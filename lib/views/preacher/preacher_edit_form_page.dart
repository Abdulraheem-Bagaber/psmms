import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/preacher.dart';
import '../../viewmodels/preacher_controller.dart';

class PreacherEditFormPage extends StatefulWidget {
  const PreacherEditFormPage({super.key, required this.preacher});

  final Preacher preacher;

  static Widget withProvider(Preacher preacher) {
    return ChangeNotifierProvider.value(
      value: PreacherController()..selectPreacher(preacher),
      child: PreacherEditFormPage(preacher: preacher),
    );
  }

  @override
  State<PreacherEditFormPage> createState() => _PreacherEditFormPageState();
}

class _PreacherEditFormPageState extends State<PreacherEditFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _specializationCtrl;
  late final TextEditingController _skillsCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.preacher;
    _nameCtrl = TextEditingController(text: p.fullName);
    _emailCtrl = TextEditingController(text: p.email ?? '');
    _phoneCtrl = TextEditingController(text: p.phone ?? '');
    _regionCtrl = TextEditingController(text: p.region);
    _specializationCtrl = TextEditingController(
      text: p.specialization.join(', '),
    );
    _skillsCtrl = TextEditingController(text: p.skills.join(', '));
    _bioCtrl = TextEditingController(text: p.bio ?? '');
  }

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
    final preacher = widget.preacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Preacher'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(controller, preacher),
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

  Future<void> _save(PreacherController controller, Preacher preacher) async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
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
      await controller.updateProfile(preacher.id, data);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preacher Profile Updated')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
