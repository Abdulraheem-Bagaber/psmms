import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'EditProfilePage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),

                const SizedBox(height: 16),

                Text(
                  data['fullName'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                ),

                const SizedBox(height: 24),

                _sectionTitle('Contact Information'),

                _infoTile(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: data['phoneNumber'],
                ),

                _infoTile(
                  icon: Icons.badge,
                  title: 'IC Number',
                  value: data['icNumber'],
                ),

                _infoTile(
                  icon: Icons.email,
                  title: 'Email',
                  value: data['email'],
                ),

                _infoTile(
                  icon: Icons.work,
                  title: 'Role',
                  value: data['role'],
                ),

                const SizedBox(height: 24),

                _sectionTitle('Qualifications'),
                ...(List.from(data['qualifications'] ?? [])
                    .map(
                      (q) => _infoTile(
                        icon: Icons.school,
                        title: 'Qualification',
                        value: q,
                      ),
                    )
                    .toList()),

                const SizedBox(height: 24),

                _sectionTitle('Skills'),
                ...(List.from(data['skills'] ?? [])
                    .map(
                      (s) => _infoTile(
                        icon: Icons.check_circle_outline,
                        title: s,
                        value: '',
                      ),
                    )
                    .toList()),
              ],
            ),
          );
        },
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

  Widget _infoTile({
    required IconData icon,
    required String title,
    String? value,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: value != null && value.isNotEmpty ? Text(value) : null,
      ),
    );
  }
}