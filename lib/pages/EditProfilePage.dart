import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/session.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final List<TextEditingController> qualificationControllers = [];
  List<TextEditingController> skillControllers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final preacherId = Session.preacherId;

    final snapshot = await FirebaseFirestore.instance
        .collection('preacher_profiles')
        .where('user_id', isEqualTo: preacherId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();

      nameController.text = data['full_name'] ?? '';
      phoneController.text = data['phone_number'] ?? '';
      addressController.text = data['address'] ?? '';
      final qualifications = List<String>.from(data['qualifications'] ?? []);
      for (final q in qualifications) {
        qualificationControllers.add(TextEditingController(text: q));
      }
      final skills = List<String>.from(data['skills'] ?? []);
      skillControllers = skills
          .map((s) => TextEditingController(text: s))
          .toList();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final preacherId = Session.preacherId;

    final snapshot = await FirebaseFirestore.instance
        .collection('preacher_profiles')
        .where('user_id', isEqualTo: preacherId)
        .limit(1)
        .get();

    final docId = snapshot.docs.first.id;

    await FirebaseFirestore.instance
        .collection('preacher_profiles')
        .doc(docId)
        .update({
      'full_name': nameController.text.trim(),
      'phone_number': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'qualifications': qualificationControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList(),
      'skills': skillControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList(),
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: isLoading
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
                      controller: addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                    ),

                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Qualifications',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    ...qualificationControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'Qualification ${index + 1}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  qualificationControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          qualificationControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Qualification'),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Skills',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    ...List.generate(skillControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: skillControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Skill ${index + 1}',
                                  prefixIcon: const Icon(Icons.star_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  skillControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          skillControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Skill'),
                    ),
                    const SizedBox(height: 24),

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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }
}