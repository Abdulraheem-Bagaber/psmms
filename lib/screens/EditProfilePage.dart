import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final icController = TextEditingController();

  final List<TextEditingController> qualificationControllers = [];
  final List<TextEditingController> skillControllers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      final data = doc.data()!;

      nameController.text = data['fullName'] ?? '';
      phoneController.text = data['phoneNumber'] ?? '';
      icController.text = data['icNumber'] ?? '';

      final qualifications = List<String>.from(data['qualifications'] ?? []);
      qualificationControllers.clear();
      for (final q in qualifications) {
        qualificationControllers.add(TextEditingController(text: q));
      }

      final skills = List<String>.from(data['skills'] ?? []);
      skillControllers.clear();
      for (final s in skills) {
        skillControllers.add(TextEditingController(text: s));
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fullName': nameController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      'icNumber': icController.text.trim(),
      'qualifications':
          qualificationControllers
              .map((c) => c.text.trim())
              .where((v) => v.isNotEmpty)
              .toList(),
      'skills':
          skillControllers
              .map((c) => c.text.trim())
              .where((v) => v.isNotEmpty)
              .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                      ),
                      _field(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                      ),
                      _field(
                        controller: icController,
                        label: 'IC Number',
                        icon: Icons.badge,
                      ),
                  
                      const SizedBox(height: 20),
                      _sectionTitle('Qualifications'),

                      ...qualificationControllers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;

                        return _dynamicField(
                          controller: c,
                          label: 'Qualification ${i + 1}',
                          onDelete:
                              () => setState(
                                () => qualificationControllers.removeAt(i),
                              ),
                        );
                      }),

                      TextButton.icon(
                        onPressed:
                            () => setState(
                              () => qualificationControllers.add(
                                TextEditingController(),
                              ),
                            ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Qualification'),
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Skills'),

                      ...skillControllers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;

                        return _dynamicField(
                          controller: c,
                          label: 'Skill ${i + 1}',
                          onDelete:
                              () => setState(
                                () => skillControllers.removeAt(i),
                              ),
                        );
                      }),

                      TextButton.icon(
                        onPressed:
                            () => setState(
                              () => skillControllers.add(
                                TextEditingController(),
                              ),
                            ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Skill'),
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator:
            (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _dynamicField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}