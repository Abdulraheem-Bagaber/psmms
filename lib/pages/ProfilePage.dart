import 'package:flutter/material.dart';
import '../pages/EditProfilePage.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 12),

            const Text(
              'Ahmad Khan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Preacher ID: 12345',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _infoTile(Icons.phone, 'Phone', '+60 12 345 6789'),
            _infoTile(Icons.email, 'Email', 'ahmad.khan@muip.org'),
            _infoTile(Icons.location_on, 'Address', 'Kuantan, Pahang'),
            _infoTile(Icons.school, 'Education', 'Masters in Islamic Studies'),
            _infoTile(Icons.work, 'Experience', '5 years'),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  );
                },
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}