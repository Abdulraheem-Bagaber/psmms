import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/session.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final preacherId = Session.preacherId;

    if (preacherId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('preacher_profiles')
            .where('user_id', isEqualTo: preacherId)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Profile not found'));
          }

          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Avatar
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  data['full_name'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Status
                Text(
                  data['profile_status'] ?? '',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle('Contact Information'),

                _infoTile(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: data['phone_number'],
                ),

                _infoTile(
                  icon: Icons.badge,
                  title: 'ID Number',
                  value: data['id_number'],
                ),

                _infoTile(
                  icon: Icons.location_on,
                  title: 'Address',
                  value: data['address'],
                ),

                const SizedBox(height: 24),

                _sectionTitle('Qualifications'),

                ...List.from(data['qualifications'] ?? []).map(
                  (q) => _infoTile(
                    icon: Icons.school,
                    title: 'Education',
                    value: q,
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle('Skills'),

                ...List.from(data['skills'] ?? []).map(
                  (s) => _infoTile(
                    icon: Icons.check_circle_outline,
                    title: s,
                    value: '',
                  ),
                ),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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


  Widget _item(String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value ?? '-'),
    );
  }
}