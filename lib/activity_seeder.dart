import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivitySeeder extends StatelessWidget {
  const ActivitySeeder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            await seedActivities();
            messenger.showSnackBar(
              const SnackBar(content: Text('Activities seeded successfully.')),
            );
          } catch (error) {
            messenger.showSnackBar(
              SnackBar(content: Text('Failed to seed activities: $error')),
            );
          }
        },
        child: const Text('Seed Activities'),
      ),
    );
  }
}

Future<void> seedActivities() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  final collection = firestore.collection('activities');

  for (final activity in _sampleActivities) {
    final docRef = collection.doc(activity.id);
    batch.set(
      docRef,
      {
        'activityId': activity.id,
        'title': activity.title,
        'preacherName': activity.preacherName,
        'preacherId': activity.preacherId,
        'activityType': activity.activityType,
        'activityDate': Timestamp.fromDate(activity.activityDate),
        'location': activity.location,
        'status': activity.status,
        'recommendedAmount': activity.recommendedAmount,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  await batch.commit();
}

class _SeedActivity {
  final String id;
  final String title;
  final String preacherName;
  final String preacherId;
  final String activityType;
  final DateTime activityDate;
  final String location;
  final String status;
  final double recommendedAmount;

  const _SeedActivity({
    required this.id,
    required this.title,
    required this.preacherName,
    required this.preacherId,
    required this.activityType,
    required this.activityDate,
    required this.location,
    required this.status,
    required this.recommendedAmount,
  });
}

final List<_SeedActivity> _sampleActivities = [
  _SeedActivity(
    id: 'ACT-1053',
    title: 'Community Outreach Sermon',
    preacherName: 'Imam Al-Ghazali',
    preacherId: 'PREACHER-001',
    activityType: 'Sermon',
    activityDate: DateTime(2024, 10, 15),
    location: 'Masjid Al-Hidayah',
    status: 'Pending Payment',
    recommendedAmount: 300.00,
  ),
  _SeedActivity(
    id: 'ACT-1052',
    title: 'Youth Guidance Workshop',
    preacherName: 'Dr. Yusuf Al-Qaradawi',
    preacherId: 'PREACHER-002',
    activityType: 'Workshop',
    activityDate: DateTime(2024, 10, 14),
    location: 'Kuala Lumpur Convention Centre',
    status: 'Pending Payment',
    recommendedAmount: 350.00,
  ),
  _SeedActivity(
    id: 'ACT-1051',
    title: 'Interfaith Dialogue',
    preacherName: 'Sheikh Hamza Yusuf',
    preacherId: 'PREACHER-001',
    activityType: 'Dialogue',
    activityDate: DateTime(2024, 10, 12),
    location: 'Putra World Trade Centre',
    status: 'paid',
    recommendedAmount: 280.00,
  ),
];
