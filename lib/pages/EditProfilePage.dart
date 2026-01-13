import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _phoneCtrl = TextEditingController(text: '+60 12 345 6789');
  final _addressCtrl = TextEditingController(text: 'Kuantan, Pahang');
  final _educationCtrl =
      TextEditingController(text: 'Masters in Islamic Studies');
  final _experienceCtrl = TextEditingController(text: '5 years');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field('Phone', _phoneCtrl),
            _field('Address', _addressCtrl),
            _field('Education', _educationCtrl),
            _field('Experience', _experienceCtrl),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // later: save to Firebase
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}