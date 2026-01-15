import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PreacherSeeder extends StatelessWidget {
  const PreacherSeeder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            await seedPreachers();
            messenger.showSnackBar(
              const SnackBar(content: Text('Preachers seeded successfully.')),
            );
          } catch (error) {
            messenger.showSnackBar(
              SnackBar(content: Text('Failed to seed preachers: $error')),
            );
          }
        },
        child: const Text('Seed Preachers'),
      ),
    );
  }
}

Future<void> seedPreachers() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('preachers');

  for (final preacher in _samplePreachers) {
    await collection.add({
      'fullName': preacher.fullName,
      'email': preacher.email,
      'phoneNumber': preacher.phone,
      'region': preacher.region,
      'specialization': preacher.specialization,
      'skills': preacher.skills,
      'bio': preacher.bio,
      'status': preacher.status,
      'rating': preacher.rating,
      'completedActivities': preacher.completedActivities,
      'approvedActivities': preacher.approvedActivities,
      'rejectedActivities': preacher.rejectedActivities,
      'paymentsTotal': preacher.paymentsTotal,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

class _SeedPreacher {
  final String fullName;
  final String email;
  final String phone;
  final String region;
  final List<String> specialization;
  final List<String> skills;
  final String bio;
  final String status;
  final double rating;
  final int completedActivities;
  final int approvedActivities;
  final int rejectedActivities;
  final double paymentsTotal;

  const _SeedPreacher({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.region,
    required this.specialization,
    required this.skills,
    required this.bio,
    required this.status,
    required this.rating,
    required this.completedActivities,
    required this.approvedActivities,
    required this.rejectedActivities,
    required this.paymentsTotal,
  });
}

final List<_SeedPreacher> _samplePreachers = [
  _SeedPreacher(
    fullName: 'Sheikh Abdullah Al-Mahmoud',
    email: 'abdullah.mahmoud@muip.org',
    phone: '+60123456789',
    region: 'Kuala Lumpur',
    specialization: ['Fiqh', 'Hadith', 'Tafsir'],
    skills: ['Public Speaking', 'Arabic Language', 'Islamic Jurisprudence'],
    bio: 'Senior Islamic scholar with 15 years of experience in teaching and preaching.',
    status: 'Active',
    rating: 4.8,
    completedActivities: 45,
    approvedActivities: 42,
    rejectedActivities: 3,
    paymentsTotal: 12500.00,
  ),
  _SeedPreacher(
    fullName: 'Ustaz Muhammad Ibrahim',
    email: 'muhammad.ibrahim@muip.org',
    phone: '+60187654321',
    region: 'Selangor',
    specialization: ['Aqidah', 'Tafsir', 'Islamic History'],
    skills: ['Youth Engagement', 'Community Outreach', 'Counseling'],
    bio: 'Passionate about youth development and community building.',
    status: 'Active',
    rating: 4.6,
    completedActivities: 38,
    approvedActivities: 36,
    rejectedActivities: 2,
    paymentsTotal: 9800.00,
  ),
  _SeedPreacher(
    fullName: 'Sheikh Hassan Al-Banna',
    email: 'hassan.banna@muip.org',
    phone: '+60198765432',
    region: 'Johor',
    specialization: ['Dakwah', 'Fiqh', 'Arabic'],
    skills: ['Interfaith Dialogue', 'Translation', 'Comparative Religion'],
    bio: 'Expert in Islamic outreach and interfaith communication.',
    status: 'Active',
    rating: 4.9,
    completedActivities: 52,
    approvedActivities: 50,
    rejectedActivities: 2,
    paymentsTotal: 15200.00,
  ),
  _SeedPreacher(
    fullName: 'Ustazah Fatimah Zahra',
    email: 'fatimah.zahra@muip.org',
    phone: '+60167890123',
    region: 'Penang',
    specialization: ['Women Studies', 'Family Law', 'Tafsir'],
    skills: ['Womens Education', 'Family Counseling', 'Social Work'],
    bio: 'Dedicated to empowering Muslim women through education.',
    status: 'Active',
    rating: 4.7,
    completedActivities: 41,
    approvedActivities: 39,
    rejectedActivities: 2,
    paymentsTotal: 10500.00,
  ),
  _SeedPreacher(
    fullName: 'Sheikh Omar Suleiman',
    email: 'omar.suleiman@muip.org',
    phone: '+60134567890',
    region: 'Kuala Lumpur',
    specialization: ['Hadith', 'Seerah', 'Contemporary Issues'],
    skills: ['Social Media', 'Modern Communication', 'Youth Programs'],
    bio: 'Modern Islamic scholar bridging tradition and contemporary life.',
    status: 'Active',
    rating: 4.9,
    completedActivities: 67,
    approvedActivities: 65,
    rejectedActivities: 2,
    paymentsTotal: 18900.00,
  ),
  _SeedPreacher(
    fullName: 'Ustaz Ali Rahman',
    email: 'ali.rahman@muip.org',
    phone: '+60145678901',
    region: 'Perak',
    specialization: ['Quran Recitation', 'Tajweed', 'Tafsir'],
    skills: ['Quran Teaching', 'Voice Training', 'Spiritual Guidance'],
    bio: 'Master of Quran recitation with beautiful voice and deep understanding.',
    status: 'Active',
    rating: 4.8,
    completedActivities: 55,
    approvedActivities: 53,
    rejectedActivities: 2,
    paymentsTotal: 14200.00,
  ),
  _SeedPreacher(
    fullName: 'Sheikh Ismail Menk',
    email: 'ismail.menk@muip.org',
    phone: '+60156789012',
    region: 'Kedah',
    specialization: ['Ethics', 'Character Building', 'Youth Development'],
    skills: ['Motivational Speaking', 'Life Coaching', 'Mental Health'],
    bio: 'Inspirational speaker focusing on character development and practical Islam.',
    status: 'Active',
    rating: 5.0,
    completedActivities: 73,
    approvedActivities: 73,
    rejectedActivities: 0,
    paymentsTotal: 21500.00,
  ),
  _SeedPreacher(
    fullName: 'Ustaz Ahmad Farouk',
    email: 'ahmad.farouk@muip.org',
    phone: '+60178901234',
    region: 'Melaka',
    specialization: ['Islamic Finance', 'Business Ethics', 'Zakat'],
    skills: ['Financial Planning', 'Business Consulting', 'Charity Management'],
    bio: 'Expert in Islamic economics and halal business practices.',
    status: 'Active',
    rating: 4.6,
    completedActivities: 34,
    approvedActivities: 32,
    rejectedActivities: 2,
    paymentsTotal: 8900.00,
  ),
  _SeedPreacher(
    fullName: 'Sheikh Hamza Yusuf',
    email: 'hamza.yusuf@muip.org',
    phone: '+60189012345',
    region: 'Sabah',
    specialization: ['Philosophy', 'Islamic Thought', 'Spirituality'],
    skills: ['Critical Thinking', 'Academic Research', 'Interfaith Studies'],
    bio: 'Scholar of Islamic philosophy and intellectual traditions.',
    status: 'Active',
    rating: 4.9,
    completedActivities: 48,
    approvedActivities: 47,
    rejectedActivities: 1,
    paymentsTotal: 13800.00,
  ),
  _SeedPreacher(
    fullName: 'Ustazah Aisha Bint Ahmad',
    email: 'aisha.ahmad@muip.org',
    phone: '+60190123456',
    region: 'Sarawak',
    specialization: ['Early Childhood Education', 'Parenting', 'Family'],
    skills: ['Child Development', 'Parent Training', 'Educational Programs'],
    bio: 'Specialist in Islamic early childhood education and family development.',
    status: 'Active',
    rating: 4.7,
    completedActivities: 39,
    approvedActivities: 37,
    rejectedActivities: 2,
    paymentsTotal: 9500.00,
  ),
];
